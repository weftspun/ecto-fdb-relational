defmodule EctoFdbRelational.Query do
  @moduledoc """
  The `DBConnection.Query` struct passed between `EctoFdbRelational.Adapter.Connection`
  and `EctoFdbRelational.Protocol`.

  `command` decides which JDBCService RPC handles the statement:

    * `:select` (and `:explain`) go to the unary `execute` RPC, which returns
      a `ResultSet`.
    * everything else (`:insert`, `:update`, `:delete`, `:ddl`, `:savepoint`, ...)
      goes to the unary `update` RPC, which returns a row count.

  There is no server-side "prepared statement" object in the JDBC gRPC
  protocol (see `jdbc.proto`'s `StatementRequest` -- it always carries the
  full SQL text plus positional parameters), so
  `EctoFdbRelational.Protocol.handle_prepare/3` is a client-side no-op and
  `name`/`ref` below exist only to satisfy `Ecto.Adapters.SQL.Connection`'s
  prepare/execute cache protocol.
  """

  @enforce_keys [:statement]
  defstruct [:name, :statement, command: :select, ref: nil]

  @type t :: %__MODULE__{
          name: String.t() | nil,
          statement: iodata(),
          command: atom(),
          ref: reference() | nil
        }
end

defimpl DBConnection.Query, for: EctoFdbRelational.Query do
  def parse(query, _opts), do: query

  def describe(query, _opts), do: query

  def encode(_query, params, _opts), do: params

  def decode(_query, result, _opts), do: result
end
