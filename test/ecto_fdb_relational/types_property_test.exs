defmodule EctoFdbRelational.TypesPropertyTest do
  @moduledoc """
  Property-based coverage for `EctoFdbRelational.Types`, complementing the
  example-based tests in `types_test.exs`. These generate many random inputs
  per run (via PropCheck/PropEr) instead of a handful of hand-picked
  examples, to catch edge cases in the scalar encode/decode/literal paths
  (empty strings, unicode, negative numbers, embedded quotes, ...) that a
  fixed example list could miss.
  """
  use ExUnit.Case, async: true
  use PropCheck

  alias EctoFdbRelational.Types

  # Every scalar Types.encode_param/1, Types.encode_literal/1 and
  # Types.decode_column/1 support in v0.1 -- see Types' moduledoc for the
  # documented scope (structs/arrays/UUID/vector are not covered here
  # because encoding them raises, by design).
  defp scalar_value do
    oneof([nil, boolean(), integer(), float(), utf8()])
  end

  property "decode_column reverses encode_param for every supported scalar value" do
    forall value <- scalar_value() do
      Types.decode_column(Types.encode_param(value)) == value
    end
  end

  property "java_sql_type_code never raises for any value encode_param accepts" do
    forall value <- scalar_value() do
      is_integer(Types.java_sql_type_code(value))
    end
  end

  property "encode_literal never raises for any value encode_param accepts" do
    forall value <- scalar_value() do
      is_binary(Types.encode_literal(value))
    end
  end

  property "encode_literal doubles every embedded single quote in a string, and wraps it in one pair of quotes" do
    forall s <- utf8() do
      encoded = Types.encode_literal(s)
      quote_count = s |> String.graphemes() |> Enum.count(&(&1 == "'"))

      String.starts_with?(encoded, "'") and
        String.ends_with?(encoded, "'") and
        count_char(encoded, ?') == 2 * quote_count + 2
    end
  end

  property "inline_literals output matches manually joining each value's own literal rendering" do
    forall values <- list(scalar_value()) do
      sql = values |> Enum.map(fn _ -> "?" end) |> Enum.join(", ")
      expected = values |> Enum.map(&Types.encode_literal/1) |> Enum.join(", ")
      Types.inline_literals(sql, values) == expected
    end
  end

  defp count_char(binary, char) do
    binary
    |> String.to_charlist()
    |> Enum.count(&(&1 == char))
  end
end
