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
    address = "#{hostname}:#{port}"

    case GRPC.Stub.connect(address, connect_opts(opts)) do
      {:ok, channel} ->
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

      {:error, reason} ->
        {:error, Error.from_reason(reason)}
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

  @impl true
  def handle_execute(%Query{statement: statement, command: command} = query, params, opts, state) do
    request = %StatementRequest{
      sql: IO.iodata_to_binary(statement),
      database: state.database,
      schema: state.schema,
      parameters: %Parameters{parameter: Enum.map(params, &encode_parameter/1)}
    }

    grpc_opts = grpc_call_opts(opts)

    rpc_fun =
      if command in [:select, :explain],
        do: &JDBCService.Stub.execute/3,
        else: &JDBCService.Stub.update/3

    call_and_decode(rpc_fun, state.channel, request, grpc_opts, query, state)
  end

  defp encode_parameter(value) do
    %Parameter{parameter: Types.encode_param(value)}
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
