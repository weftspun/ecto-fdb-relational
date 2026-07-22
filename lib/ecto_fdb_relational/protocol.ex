defmodule EctoFdbRelational.Protocol do
  @moduledoc """
  A `DBConnection` behaviour implementation that speaks gRPC directly to
  `fdb-relational-server`'s `grpc.relational.jdbc.v1.JDBCService` (see the
  vendored `priv/protos/grpc/relational/jdbc/v1/*.proto` and the ADR in the
  README for why this talks gRPC instead of going through JDBC/a JVM).

  One `DBConnection` connection == one `GRPC.Channel` (one HTTP/2 connection
  to `fdb-relational-server`). `DBConnection`'s own pool
  (`DBConnection.ConnectionPool`) provides concurrency, checkout/checkin,
  and backoff/reconnection -- we don't reimplement any of that here.

  ## Required `opts` (set via `Ecto.Repo` config, see README):

    * `:hostname` - defaults to `"localhost"`
    * `:port` - **required**, the `-g` gRPC port `fdb-relational-server` was
      started with
    * `:database` - **required**, e.g. `"/frl/my_app"`
    * `:relational_schema` - defaults to `"PUBLIC"`, the schema instantiated
      via `CREATE SCHEMA /frl/my_app/PUBLIC WITH TEMPLATE ...`

  ## Transactions (known gap)

  FRL's gRPC service only exposes true multi-statement transactions through
  the bidirectional-streaming `handleAutoCommitOff` RPC, which requires
  holding a long-lived stream + server-assigned transaction state across
  calls. That is not implemented in v0.1 -- see the README "Known gaps"
  section. `handle_begin/2`, `handle_commit/2` and `handle_rollback/2` below
  are **no-ops that do not provide atomicity or isolation**; each individual
  statement is auto-committed by the server exactly as if you called it
  outside of `Repo.transaction/2`. This is called out loudly rather than
  silently pretended away.
  """

  @behaviour DBConnection

  alias EctoFdbRelational.{Error, Query, Types}

  alias Grpc.Relational.Jdbc.V1.{
    JDBCService,
    Parameter,
    Parameters,
    StatementRequest
  }

  defstruct [:channel, :database, :schema, :address]

  @default_hostname "localhost"
  @default_schema "PUBLIC"

  ## DBConnection callbacks

  @impl true
  def connect(opts) do
    hostname = Keyword.get(opts, :hostname, @default_hostname)

    port =
      Keyword.get(opts, :port) ||
        raise ArgumentError,
              "EctoFdbRelational requires :port (the -g gRPC port fdb-relational-server " <>
                "was started with) in the Repo config"

    database =
      Keyword.get(opts, :database) ||
        raise ArgumentError,
              "EctoFdbRelational requires :database (e.g. \"/frl/my_app\") in the Repo config"

    relational_schema = Keyword.get(opts, :relational_schema, @default_schema)

    with {:ok, ip} <- :inet.getaddr(String.to_charlist(hostname), :inet),
         address = "#{:inet.ntoa(ip)}:#{port}",
         {:ok, channel} <- GRPC.Stub.connect(address, connect_opts(opts)) do
      # See EctoFdbRelational.Ddl moduledoc: execute_ddl/1 has no access to
      # repo config, so we stash the target database/schema here, the
      # first point at which we definitely have it and definitely run
      # before any migration can execute.
      EctoFdbRelational.Ddl.put_ddl_context(database, relational_schema)

      {:ok,
       %__MODULE__{
         channel: channel,
         database: database,
         schema: relational_schema,
         address: address
       }}
    else
      {:error, reason} -> {:error, Error.from_reason(reason)}
    end
  end

  defp connect_opts(opts) do
    if Keyword.get(opts, :ssl, false) do
      []
    else
      [cred: nil]
    end
  end

  @impl true
  def disconnect(_err, %__MODULE__{channel: channel}) do
    GRPC.Stub.disconnect(channel)
    :ok
  end

  @impl true
  def checkout(%__MODULE__{} = state), do: {:ok, state}

  @impl true
  def ping(%__MODULE__{} = state) do
    alias Grpc.Relational.Jdbc.V1.DatabaseMetaDataRequest

    case JDBCService.Stub.get_meta_data(state.channel, %DatabaseMetaDataRequest{}) do
      {:ok, _resp} -> {:ok, state}
      {:error, %GRPC.RPCError{} = err} -> {:disconnect, Error.from_rpc_error(err), state}
      {:error, reason} -> {:disconnect, Error.from_reason(reason), state}
    end
  end

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
  # fdb-relational-server rejects *every* StatementRequest whose `database`
  # field names something that doesn't exist -- including a database that
  # was just created in a prior statement on the same connection, which
  # rules out simply passing the real target once it should exist -- so
  # EctoFdbRelational.Ddl's bootstrap statements (and this test's) must all
  # be sent against "/__SYS"/"CATALOG" rather than the Repo's configured
  # :database/:relational_schema. Only regular DML against an already-
  # provisioned schema uses the Repo's configured database/schema.
  @catalog_database "/__SYS"
  @catalog_schema "CATALOG"
  @catalog_level_ddl ~r/\A\s*(CREATE|DROP)\s+(DATABASE|SCHEMA)\b/i

  # fdb-relational-server 4.3.6.0's query planner has a confirmed bug
  # (reproduced with a minimal, no-gRPC Java program calling FRL
  # directly -- see Types.encode_literal/1's moduledoc) where an
  # `UPDATE ... SET x = ? WHERE y = ?` statement -- a bound parameter in
  # *both* the SET and WHERE clauses -- fails query planning entirely,
  # even though the same two parameters bind correctly in a `SELECT`.
  # Rather than depend on an upstream fix, :update statements carrying
  # parameters have them inlined as SQL literals instead of bound, which
  # sidesteps that planner path -- proven reliable throughout this
  # adapter's own DDL/bootstrap statements, which have always been plain
  # literal text.
  @literal_inlined_commands [:update]

  @impl true
  def handle_execute(%Query{statement: statement, command: command} = query, params, opts, state) do
    sql = IO.iodata_to_binary(statement)

    {database, schema} =
      if Regex.match?(@catalog_level_ddl, sql),
        do: {@catalog_database, @catalog_schema},
        else: {state.database, state.schema}

    {sql, params} =
      if command in @literal_inlined_commands and params != [],
        do: {Types.inline_literals(sql, params), []},
        else: {sql, params}

    request = %StatementRequest{
      sql: sql,
      database: database,
      schema: schema,
      parameters: %Parameters{parameter: Enum.map(params, &encode_parameter/1)}
    }

    grpc_opts = grpc_call_opts(opts)

    # fdb-relational-server's `update` RPC handler drops parameters
    # entirely (it calls FRL.update(database, schema, sql) -- no
    # parameters argument exists on that method), executing the raw SQL
    # text with its "?" placeholders unbound. Only `execute` forwards
    # StatementRequest.parameters through to a real PreparedStatement
    # (FRL.execute(..., parameters, ...)), and it handles mutations fine
    # too -- FRL.execute returns either a ResultSet or an update count
    # depending on the statement. So any statement carrying parameters
    # must go through `execute`, regardless of :select vs :insert/etc.
    rpc_fun =
      if command in [:select, :explain] or params != [],
        do: &JDBCService.Stub.execute/3,
        else: &JDBCService.Stub.update/3

    call_and_decode(rpc_fun, state.channel, request, grpc_opts, query, state)
  end

  defp encode_parameter(value) do
    # java_sql_types_code is what fdb-relational-server actually switches
    # on to bind this parameter server-side (see Types.java_sql_type_code/1
    # moduledoc) -- without it every parameterized statement silently
    # binds nothing.
    %Parameter{
      parameter: Types.encode_param(value),
      java_sql_types_code: Types.java_sql_type_code(value)
    }
  end

  defp grpc_call_opts(opts) do
    case Keyword.get(opts, :timeout) do
      nil -> []
      timeout -> [timeout: timeout]
    end
  end

  defp call_and_decode(rpc_fun, channel, request, grpc_opts, query, state) do
    case rpc_fun.(channel, request, grpc_opts) do
      {:ok, response} ->
        {:ok, query, decode_response(response), state}

      {:error, %GRPC.RPCError{} = err} ->
        {:error, Error.from_rpc_error(err), state}

      {:error, reason} ->
        {:error, Error.from_reason(reason), state}
    end
  rescue
    e in EctoFdbRelational.Error -> {:error, e, state}
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

  ## Transactions -- see moduledoc. These intentionally do not talk to the
  ## server: real cross-statement atomicity would require the
  ## `handleAutoCommitOff` bidi-streaming RPC, which is not implemented yet.

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
