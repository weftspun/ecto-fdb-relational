defmodule EctoFdbRelational.Types do
  @moduledoc """
  Converts between Elixir/Ecto values and the wire types defined in
  `grpc/relational/jdbc/v1/column.proto` (the `Column` oneof used both for
  query parameters going out and result-set cells coming back).

  Column proto reference (vendored at `priv/protos/grpc/relational/jdbc/v1/column.proto`):

      message Column {
        oneof kind {
          NullColumn null = 1;   // deprecated
          double double = 2;
          int32 integer = 3;
          int64 long = 4;
          string string = 5;
          bool boolean = 6;
          Struct struct = 7;
          Array array = 8;
          bytes binary = 9;
          float float = 10;
          int32 nullType = 11;
          Uuid uuid = 12;
        }
      }

  ## Scope (v0.1)

  Only the scalar types needed for basic CRUD are handled: long/integer,
  string, boolean, double/float, binary, and null. `Struct`, `Array`,
  `Uuid`, `Enum` and `Vector` (FRL's richer type system, see
  `SQL_Getting_Started.md`) are **not** converted yet -- see the README
  "Known gaps" section. Attempting to encode/decode one of those raises
  `EctoFdbRelational.Error` rather than silently corrupting data.
  """

  alias Grpc.Relational.Jdbc.V1.Column

  @doc """
  Encodes an Elixir term (already dumped by Ecto's type system) into a
  `Column` message suitable for `StatementRequest.parameters`.
  """
  @spec encode_param(term()) :: Column.t()
  def encode_param(nil), do: %Column{kind: {:nullType, 0}}
  def encode_param(value) when is_boolean(value), do: %Column{kind: {:boolean, value}}
  def encode_param(value) when is_integer(value), do: %Column{kind: {:long, value}}
  def encode_param(value) when is_float(value), do: %Column{kind: {:double, value}}
  def encode_param(%Decimal{} = value), do: %Column{kind: {:double, Decimal.to_float(value)}}
  def encode_param(value) when is_binary(value), do: %Column{kind: {:string, value}}

  def encode_param(value) do
    raise EctoFdbRelational.Error,
      message:
        "EctoFdbRelational.Types.encode_param/1 does not know how to encode #{inspect(value)} " <>
          "as a Column proto message yet (structs/arrays/UUID/vector params are not implemented in v0.1)"
  end

  # java.sql.Types constants. FRL's own server-side parameter binding
  # (fdb-relational-server's FRL.addPreparedStatementParameter) switches
  # on Parameter.java_sql_types_code to decide which RelationalPreparedStatement
  # setter to call -- despite that field being marked `[deprecated = true]`
  # in jdbc.proto, it is the one thing that actually drives binding. A
  # Parameter with only `parameter` (the Column) set and no
  # java_sql_types_code silently binds nothing: the switch falls through
  # with no matching case, leaving that placeholder unbound. Every
  # parameter this adapter sends must carry the matching code.
  @sql_type_null 0
  @sql_type_bigint -5
  @sql_type_double 8
  @sql_type_varchar 12
  @sql_type_boolean 16

  @doc """
  The `java.sql.Types` constant matching `encode_param/1`'s choice of
  `Column` variant for `value`, for `Parameter.java_sql_types_code`.
  """
  @spec java_sql_type_code(term()) :: integer()
  def java_sql_type_code(nil), do: @sql_type_null
  def java_sql_type_code(value) when is_boolean(value), do: @sql_type_boolean
  def java_sql_type_code(value) when is_integer(value), do: @sql_type_bigint
  def java_sql_type_code(value) when is_float(value), do: @sql_type_double
  def java_sql_type_code(%Decimal{}), do: @sql_type_double
  def java_sql_type_code(value) when is_binary(value), do: @sql_type_varchar

  def java_sql_type_code(value) do
    raise EctoFdbRelational.Error,
      message:
        "EctoFdbRelational.Types.java_sql_type_code/1 does not know how to encode " <>
          "#{inspect(value)} yet (structs/arrays/UUID/vector params are not implemented in v0.1)"
  end

  @doc """
  Decodes a `Column` message (a result-set cell) back into a plain Elixir
  term. Returns `nil` for both the deprecated `null` variant and the typed
  `nullType` variant.
  """
  @spec decode_column(Column.t()) :: term()
  def decode_column(%Column{kind: nil}), do: nil
  def decode_column(%Column{kind: {:null, _}}), do: nil
  def decode_column(%Column{kind: {:nullType, _}}), do: nil
  def decode_column(%Column{kind: {:boolean, v}}), do: v
  def decode_column(%Column{kind: {:integer, v}}), do: v
  def decode_column(%Column{kind: {:long, v}}), do: v
  def decode_column(%Column{kind: {:double, v}}), do: v
  def decode_column(%Column{kind: {:float, v}}), do: v
  def decode_column(%Column{kind: {:string, v}}), do: v
  def decode_column(%Column{kind: {:binary, v}}), do: v

  def decode_column(%Column{kind: {tag, _v}}) do
    raise EctoFdbRelational.Error,
      message:
        "EctoFdbRelational.Types.decode_column/1 received a Column of kind #{inspect(tag)}, " <>
          "which isn't decoded yet (struct/array/uuid support is not implemented in v0.1)"
  end

  @doc """
  Maps an Ecto primitive type to an FRL DDL column type, per
  `SQL_Getting_Started.md` (STRING/BIGINT/BOOLEAN/DOUBLE/BYTES -- FRL's own
  dialect, not standard SQL VARCHAR/INT).
  """
  @spec ddl_type(atom() | tuple()) :: String.t()
  def ddl_type(:id), do: "BIGINT"
  def ddl_type(:integer), do: "BIGINT"
  def ddl_type(:bigint), do: "BIGINT"
  def ddl_type(:string), do: "STRING"
  def ddl_type(:boolean), do: "BOOLEAN"
  def ddl_type(:float), do: "DOUBLE"
  def ddl_type(:decimal), do: "DOUBLE"
  def ddl_type(:binary), do: "BYTES"
  def ddl_type(:utc_datetime), do: "BIGINT"
  def ddl_type(:naive_datetime), do: "BIGINT"
  def ddl_type(:utc_datetime_usec), do: "BIGINT"
  def ddl_type(:naive_datetime_usec), do: "BIGINT"

  def ddl_type(other) do
    raise EctoFdbRelational.Error,
      message:
        "EctoFdbRelational has no FRL DDL type mapping for #{inspect(other)} yet. " <>
          "Supported column types in v0.1 are: id/integer/bigint, string, boolean, " <>
          "float/decimal, binary, and the *_datetime family (stored as BIGINT epoch millis). " <>
          "FRL's STRUCT/ARRAY/VECTOR/ENUM types (see SQL_Getting_Started.md) are not mapped yet."
  end
end
