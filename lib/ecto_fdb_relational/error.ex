defmodule EctoFdbRelational.Error do
  @moduledoc """
  Wraps a failure calling into FRL through `EctoFdbRelational.Native` (a Java exception
  message flattened by the NIF, a JVM/attach-thread failure, or a malformed-response
  condition detected while decoding a `StatementResponse`) in an `Exception` so
  DBConnection/Ecto can surface it consistently.
  """

  defexception [:message]

  @type t :: %__MODULE__{message: String.t()}

  @doc false
  def from_reason(reason) do
    %__MODULE__{message: "EctoFdbRelational.Native call failed: #{format_reason(reason)}"}
  end

  defp format_reason(reason) when is_binary(reason), do: reason
  defp format_reason(reason), do: inspect(reason)
end
