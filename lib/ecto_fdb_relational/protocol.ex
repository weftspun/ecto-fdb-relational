defmodule EctoFdbRelational.Protocol do
  @moduledoc """
  A `DBConnection` behaviour implementation that runs FRL **in-process** through
  `EctoFdbRelational.Native` (a Rustler NIF embedding a JVM via JNI -- see ADR 0003 for
  why this replaced talking gRPC to a separately-managed `fdb-relational-server`
  process, which this adapter no longer does at all).

  One `DBConnection` connection == one embedded FRL instance (a JVM object reference
  held by the NIF). `DBConnection`'s own pool (`DBConnection.ConnectionPool`) provides
  concurrency, checkout/checkin, and backoff/reconnection -- we don't reimplement any
  of that here.

  The wire *shape* is unchanged from the old gRPC transport: `EctoFdbRelational.Native`
  passes and returns raw `grpc.relational.jdbc.v1.{StatementRequest,StatementResponse}`
  protobuf bytes (FRL's own internal request/response shape, used here with no gRPC
  service involved -- see `EctoFdbRelational.Native`'s moduledoc). Only how those bytes
  get to FRL changed.

  ## Required `opts` (set via `Ecto.Repo` config, see README):

    * `:cluster_file` - **required**, path to the FoundationDB cluster file (what
      `FDB_CLUSTER_FILE` pointed at for the old gRPC-based `fdb-relational-server`
      process, which this adapter no longer starts or talks to)
    * `:database` - **required**, e.g. `"/frl/my_app"`
    * `:relational_schema` - defaults to `"PUBLIC"`, the schema instantiated
      via `CREATE SCHEMA /frl/my_app/PUBLIC WITH TEMPLATE ...`

  ## Transactions (known gap)

  FRL's `FRL.execute`/`FRL.update` are effectively autocommit-per-call, same as the old
  gRPC `JDBCService.execute`/`update` RPCs were -- see the README "Known gaps" section.
  `handle_begin/2`, `handle_commit/2` and `handle_rollback/2` below are **no-ops that do
  not provide atomicity or isolation**; each individual statement commits exactly as if
  you called it outside of `Repo.transaction/2`. This is called out loudly rather than
  silently pretended away.

  ## No crash isolation (known gap, see ADR 0003)

  A JVM segfault, native OOM, or a panic/exception crossing the Rust<->JNI boundary
  uncleanly crashes the whole BEAM node -- there is no separate process to lose a
  connection to and recover from anymore. `ping/2` is a no-op for exactly this reason:
  the old gRPC transport used it to detect a stale/dead remote connection while pooled;
  here, "the connection" is just a JVM object reference in the same OS process, so a
  real failure of the embedded JVM takes the whole node down before a pooled
  connection's staleness would ever matter.
  """

  @behaviour DBConnection

  alias EctoFdbRelational.{Error, Native, Query, Types}
  alias Grpc.Relational.Jdbc.V1.{Parameter, Parameters, StatementRequest, StatementResponse}

  defstruct [:conn, :database, :schema, :cluster_file]

  @default_schema "PUBLIC"

  ## DBConnection callbacks

  @impl true
  def connect(opts) do
    cluster_file =
      Keyword.get(opts, :cluster_file) ||
        raise ArgumentError,
              "EctoFdbRelational requires :cluster_file (the FoundationDB cluster file " <>
                "path) in the Repo config"

    database =
      Keyword.get(opts, :database) ||
        raise ArgumentError,
              "EctoFdbRelational requires :database (e.g. \"/frl/my_app\") in the Repo config"

    relational_schema = Keyword.get(opts, :relational_schema, @default_schema)

    case Native.connect(cluster_file) do
      {:error, reason} ->
        {:error, Error.from_reason(reason)}

      conn ->
        # See EctoFdbRelational.Ddl moduledoc: execute_ddl/1 has no access to
        # repo config, so we stash the target database/schema here, the
        # first point at which we definitely have it and definitely run
        # before any migration can execute.
        EctoFdbRelational.Ddl.put_ddl_context(database, relational_schema)

        {:ok,
         %__MODULE__{
           conn: conn,
           database: database,
           schema: relational_schema,
           cluster_file: cluster_file
         }}
    end
  end

  @impl true
  def disconnect(_err, %__MODULE__{conn: conn}) do
    case Native.close(conn) do
      :ok -> :ok
      {:error, _reason} -> :ok
    end
  end

  @impl true
  def checkout(%__MODULE__{} = state), do: {:ok, state}

  # See moduledoc: a no-op by design, not an oversight -- there is no separate
  # remote process for this transport whose liveness would be worth polling.
  @impl true
  def ping(%__MODULE__{} = state), do: {:ok, state}

  # There is no server-side prepared-statement handle in this wire protocol
  # (see moduledoc) -- prepare is purely a client-side bookkeeping step.
  @impl true
  def handle_prepare(%Query{} = query, _opts, state) do
    {:ok, query, state}
  end

  # FRL's own JDBC quick-start runs *every* catalog-level DDL statement --
  # CREATE/DROP DATABASE, CREATE/DROP SCHEMA TEMPLATE, and even
  # "CREATE SCHEMA /path/name WITH TEMPLATE ..." itself (which names a
  # database that was only just created earlier in the same bootstrap
  # sequence) -- over one connection to this exact well-known, always-
  # existing system database/schema ("jdbc:embed:/__SYS?schema=CATALOG").
  # FRL rejects *every* statement whose `database` field names something
  # that doesn't exist -- including a database that was just created in a
  # prior statement on the same connection, which rules out simply passing
  # the real target once it should exist -- so EctoFdbRelational.Ddl's
  # bootstrap statements (and this test's) must all be sent against
  # "/__SYS"/"CATALOG" rather than the Repo's configured
  # :database/:relational_schema. Only regular DML against an already-
  # provisioned schema uses the Repo's configured database/schema.
  @catalog_database "/__SYS"
  @catalog_schema "CATALOG"
  @catalog_level_ddl ~r/\A\s*(CREATE|DROP)\s+(DATABASE|SCHEMA)\b/i

  # fdb-relational-server 4.3.6.0's query planner has a confirmed bug
  # (reproduced with a minimal, no-gRPC Java program calling FRL directly --
  # see Types.encode_literal/1's moduledoc, and spike/jvm_embed's
  # EmbeddedSpike.java, which this transport's native/frl_bridge grew out
  # of) where an `UPDATE ... SET x = ? WHERE y = ?` statement -- a bound
  # parameter in *both* the SET and WHERE clauses -- fails query planning
  # entirely, even though the same two parameters bind correctly in a
  # `SELECT`. Rather than depend on an upstream fix, UPDATE statements
  # carrying parameters have them inlined as SQL literals instead of bound,
  # which sidesteps that planner path -- proven reliable throughout this
  # adapter's own DDL/bootstrap statements, which have always been plain
  # literal text.
  #
  # Detected via the SQL text itself, not `Query.command`: `command` comes
  # from the `:command` key `Adapter.Connection.prepare_execute/5` reads out
  # of `opts`, but `ecto_sql`'s own generic `Ecto.Adapters.SQL.execute/6`
  # (what actually runs for `Repo.update_all/2`, same as `Repo.all/2`) never
  # sets that key -- every Ecto.Query-driven call, `update_all` included,
  # arrives here with `command: :select` regardless of what the SQL text
  # says.
  @update_statement ~r/\AUPDATE\s/i

  @impl true
  def handle_execute(%Query{statement: statement} = query, params, _opts, state) do
    sql = IO.iodata_to_binary(statement)

    {database, schema} =
      if Regex.match?(@catalog_level_ddl, sql),
        do: {@catalog_database, @catalog_schema},
        else: {state.database, state.schema}

    {sql, params} =
      if Regex.match?(@update_statement, sql) and params != [],
        do: {Types.inline_literals(sql, params), []},
        else: {sql, params}

    request = %StatementRequest{
      sql: sql,
      database: database,
      schema: schema,
      parameters: %Parameters{parameter: Enum.map(params, &encode_parameter/1)}
    }

    request_bytes = request |> StatementRequest.encode() |> IO.iodata_to_binary()

    # Always the same call FRL's own `execute` handles, never a separate
    # "update" path: FRL.execute forwards parameters through to a real
    # PreparedStatement when present, and handles plain non-parameterized
    # statements (DDL, literal-inlined UPDATEs) via the same path regardless,
    # returning either a ResultSet or an update count depending on what the
    # SQL actually is.
    case Native.execute(state.conn, request_bytes) do
      {:error, reason} ->
        {:error, Error.from_reason(reason), state}

      response_bytes ->
        response = StatementResponse.decode(response_bytes)
        {:ok, query, decode_response(response), state}
    end
  rescue
    e in EctoFdbRelational.Error -> {:error, e, state}
  end

  defp encode_parameter(value) do
    # java_sql_types_code is what FRL actually switches on to bind this
    # parameter server-side (see Types.java_sql_type_code/1 moduledoc) --
    # without it every parameterized statement silently binds nothing.
    %Parameter{
      parameter: Types.encode_param(value),
      java_sql_types_code: Types.java_sql_type_code(value)
    }
  end

  defp decode_response(%{row_count: row_count, result_set: nil}) do
    %{num_rows: row_count, rows: nil, columns: nil}
  end

  defp decode_response(%{row_count: row_count, result_set: result_set}) do
    columns = column_names(result_set.metadata)
    rows = Enum.map(result_set.row, &decode_row/1)
    num_rows = if rows == [], do: row_count, else: length(rows)
    %{num_rows: num_rows, rows: rows, columns: columns}
  end

  defp column_names(nil), do: nil

  defp column_names(%{columnMetadata: nil}), do: nil

  defp column_names(%{columnMetadata: %{columnMetadata: metadata}}) do
    Enum.map(metadata, & &1.name)
  end

  defp decode_row(%{columns: %{column: columns}}) do
    Enum.map(columns, &Types.decode_column/1)
  end

  defp decode_row(_), do: []

  ## Transactions -- see moduledoc. These intentionally do not talk to FRL:
  ## real cross-statement atomicity isn't implemented yet (see the README).

  @impl true
  def handle_begin(_opts, state), do: {:ok, %{}, state}

  @impl true
  def handle_commit(_opts, state), do: {:ok, %{}, state}

  @impl true
  def handle_rollback(_opts, state), do: {:ok, %{}, state}

  @impl true
  def handle_status(_opts, state), do: {:idle, state}

  @impl true
  def handle_close(_query, _opts, state), do: {:ok, %{}, state}

  @impl true
  def handle_declare(_query, _params, _opts, state) do
    {:error, Error.from_reason(:cursors_not_supported), state}
  end

  @impl true
  def handle_fetch(_query, _cursor, _opts, state) do
    {:error, Error.from_reason(:cursors_not_supported), state}
  end

  @impl true
  def handle_deallocate(_query, _cursor, _opts, state) do
    {:error, Error.from_reason(:cursors_not_supported), state}
  end
end
