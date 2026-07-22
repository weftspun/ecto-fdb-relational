defmodule EctoFdbRelational.Error do
  @moduledoc """
  Wraps errors coming back from `fdb-relational-server`'s gRPC `JDBCService`
  (a `GRPC.RPCError`, a transport-level `GRPC.Channel` failure, or a
  malformed-response condition detected while decoding a `ResultSet`) in an
  `Exception` so DBConnection / Ecto can surface it consistently.
  """

  defexception [:message, :grpc_status, :grpc_reason]

  @type t :: %__MODULE__{
          message: String.t(),
          grpc_status: non_neg_integer() | nil,
          grpc_reason: term()
        }

  @doc false
  def from_rpc_error(%GRPC.RPCError{status: status, message: message}) do
    %__MODULE__{
      message: "fdb-relational-server returned gRPC status #{status}: #{message}",
      grpc_status: status,
      grpc_reason: message
    }
  end

  def from_reason(reason) do
    %__MODULE__{message: "fdb-relational-server request failed: #{inspect(reason)}"}
  end
end
