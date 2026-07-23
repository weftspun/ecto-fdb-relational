defmodule EctoFdbRelational.TypesTest do
  @moduledoc """
  Unit tests for `EctoFdbRelational.Types` -- no live server needed.
  """
  use ExUnit.Case, async: true

  alias EctoFdbRelational.Types
  alias Grpc.Relational.Jdbc.V1.{Column, Parameter, Parameters}

  describe "encode_param/1" do
    test "encodes each supported Elixir value as the matching Column oneof variant" do
      assert %Column{kind: {:nullType, 0}} = Types.encode_param(nil)
      assert %Column{kind: {:boolean, true}} = Types.encode_param(true)
      assert %Column{kind: {:long, 42}} = Types.encode_param(42)
      assert %Column{kind: {:double, 1.5}} = Types.encode_param(1.5)
      assert %Column{kind: {:string, "hi"}} = Types.encode_param("hi")
    end

    test "encodes a Decimal as a double" do
      assert %Column{kind: {:double, 1.5}} = Types.encode_param(Decimal.new("1.5"))
    end

    # Regression coverage: Ecto.Migrator's own SchemaMigration always
    # inserts a NaiveDateTime into schema_migrations.inserted_at, so
    # without this, no migration could run against this adapter at all --
    # not a hypothetical, this reproduced against a real cluster. See
    # ddl_type/1's *_datetime -> BIGINT mapping, which this matches.
    test "encodes a NaiveDateTime as epoch-millis, matching ddl_type/1's BIGINT mapping" do
      assert %Column{kind: {:long, 0}} = Types.encode_param(~N[1970-01-01 00:00:00])
      assert %Column{kind: {:long, 1000}} = Types.encode_param(~N[1970-01-01 00:00:01])

      assert %Column{kind: {:long, millis}} = Types.encode_param(~N[2024-01-01 00:00:00.500])

      assert millis ==
               NaiveDateTime.diff(
                 ~N[2024-01-01 00:00:00.500],
                 ~N[1970-01-01 00:00:00],
                 :millisecond
               )
    end

    test "encodes a DateTime as epoch-millis" do
      assert %Column{kind: {:long, 0}} = Types.encode_param(~U[1970-01-01 00:00:00Z])
      assert %Column{kind: {:long, 1000}} = Types.encode_param(~U[1970-01-01 00:00:01Z])
    end

    test "raises a clear error for values it doesn't know how to encode yet" do
      assert_raise EctoFdbRelational.Error, ~r/does not know how to encode/, fn ->
        Types.encode_param({:a, :tuple})
      end
    end
  end

  describe "java_sql_type_code/1" do
    # fdb-relational-server's own FRL.addPreparedStatementParameter switches
    # on this field to decide which RelationalPreparedStatement setter to
    # call -- it must match encode_param/1's choice of Column variant for
    # the same value, or the parameter silently binds nothing server-side
    # (see EctoFdbRelational.Protocol.encode_parameter/1's moduledoc note).
    test "matches java.sql.Types constants for each supported value type" do
      assert Types.java_sql_type_code(nil) == 0
      assert Types.java_sql_type_code(true) == 16
      assert Types.java_sql_type_code(42) == -5
      assert Types.java_sql_type_code(1.5) == 8
      assert Types.java_sql_type_code(Decimal.new("1.5")) == 8
      assert Types.java_sql_type_code("hi") == 12
      assert Types.java_sql_type_code(~N[2024-01-01 00:00:00]) == -5
      assert Types.java_sql_type_code(~U[2024-01-01 00:00:00Z]) == -5
    end
  end

  describe "encode_literal/1" do
    # Used to inline :update parameters as SQL text instead of binding
    # them, working around a confirmed fdb-relational-server 4.3.6.0
    # query-planner bug for UPDATE ... SET x = ? WHERE y = ? statements
    # (see EctoFdbRelational.Protocol's @literal_inlined_commands and
    # Types.encode_literal/1's own moduledoc for the full story).
    test "renders each supported value as FRL SQL literal syntax" do
      assert Types.encode_literal(nil) == "NULL"
      assert Types.encode_literal(true) == "TRUE"
      assert Types.encode_literal(false) == "FALSE"
      assert Types.encode_literal(42) == "42"
      assert Types.encode_literal(-7) == "-7"
      assert Types.encode_literal(1.5) == "1.5"
      assert Types.encode_literal(Decimal.new("1.5")) == "1.5"
      assert Types.encode_literal("Alice") == "'Alice'"
      assert Types.encode_literal(~N[1970-01-01 00:00:01]) == "1000"
      assert Types.encode_literal(~U[1970-01-01 00:00:01Z]) == "1000"
    end

    test "escapes embedded single quotes by doubling them (the SQL-standard escape)" do
      assert Types.encode_literal("O'Brien") == "'O''Brien'"
      assert Types.encode_literal("''") == "''''''"
    end

    test "raises a clear error for values it doesn't know how to render yet" do
      assert_raise EctoFdbRelational.Error, ~r/does not know how to render/, fn ->
        Types.encode_literal({:a, :tuple})
      end
    end
  end

  describe "inline_literals/2" do
    test "substitutes each ? placeholder with its literal, in order" do
      assert Types.inline_literals("SET name = ? WHERE id = ?", ["Alice", 1]) ==
               "SET name = 'Alice' WHERE id = 1"
    end

    test "handles a single placeholder" do
      assert Types.inline_literals("WHERE id = ?", [1]) == "WHERE id = 1"
    end

    test "handles no placeholders (empty params)" do
      assert Types.inline_literals("SELECT 1", []) == "SELECT 1"
    end

    test "escapes string values with embedded quotes when inlined" do
      assert Types.inline_literals("SET name = ?", ["O'Brien"]) == "SET name = 'O''Brien'"
    end

    test "handles nil and boolean values" do
      assert Types.inline_literals("SET a = ?, b = ? WHERE c = ?", [nil, true, false]) ==
               "SET a = NULL, b = TRUE WHERE c = FALSE"
    end
  end

  describe "Parameters protobuf round-trip (no live server)" do
    # Regression coverage for the client-side wire encoding of
    # StatementRequest.parameters: build a Parameters message the same
    # way EctoFdbRelational.Protocol.encode_parameter/1 does, run it
    # through a real binary encode/decode round-trip via the generated
    # protobuf module, and confirm every entry survives in order. Written
    # while chasing a multi-parameter query-planner bug that turned out
    # to be server-side (see Types.encode_literal/1's moduledoc) rather
    # than a client-side encoding defect -- kept as general regression
    # coverage for the encoding itself, which this ruled out as sound.
    defp build_parameter(value) do
      %Parameter{
        parameter: Types.encode_param(value),
        java_sql_types_code: Types.java_sql_type_code(value)
      }
    end

    test "a single parameter survives an encode/decode round-trip" do
      params = %Parameters{parameter: [build_parameter(1)]}

      assert params
             |> Parameters.encode()
             |> IO.iodata_to_binary()
             |> Parameters.decode() == params
    end

    test "multiple parameters of mixed types preserve both order and value" do
      values = [1, "two", 3.0, false, nil]
      params = %Parameters{parameter: Enum.map(values, &build_parameter/1)}

      decoded =
        params
        |> Parameters.encode()
        |> IO.iodata_to_binary()
        |> Parameters.decode()

      assert decoded == params
      assert Enum.map(decoded.parameter, &Types.decode_column(&1.parameter)) == values
    end
  end

  describe "decode_column/1" do
    test "decodes every Column variant encode_param/1 can produce back to the original value" do
      for value <- [nil, true, false, 42, 1.5, "hi", ""] do
        assert Types.decode_column(Types.encode_param(value)) == value
      end
    end

    test "decodes the deprecated null variant and the typed nullType variant both as nil" do
      assert Types.decode_column(%Column{kind: {:null, %{}}}) == nil
      assert Types.decode_column(%Column{kind: {:nullType, 0}}) == nil
    end

    # Documents the write-only asymmetry deliberately, rather than letting
    # it be silently rediscovered: encode_param/1 turns a NaiveDateTime
    # into a plain BIGINT Column, and decode_column/1 has no *_datetime
    # case, so it comes back as a plain integer, not a NaiveDateTime.
    test "a NaiveDateTime written via encode_param/1 decodes back as a plain integer, not a struct" do
      value = ~N[2024-01-01 00:00:01]
      assert Types.decode_column(Types.encode_param(value)) == 1_704_067_201_000
    end
  end

  describe "epoch_millis/1" do
    test "converts a NaiveDateTime to milliseconds since the Unix epoch" do
      assert Types.epoch_millis(~N[1970-01-01 00:00:00]) == 0
      assert Types.epoch_millis(~N[1970-01-01 00:00:01]) == 1000
      assert Types.epoch_millis(~N[1969-12-31 23:59:59]) == -1000
    end

    test "converts a DateTime to milliseconds since the Unix epoch" do
      assert Types.epoch_millis(~U[1970-01-01 00:00:00Z]) == 0
      assert Types.epoch_millis(~U[1970-01-01 00:00:01Z]) == 1000
    end
  end
end
