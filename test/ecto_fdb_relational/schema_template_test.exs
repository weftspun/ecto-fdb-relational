defmodule EctoFdbRelational.SchemaTemplateTest do
  @moduledoc """
  Unit tests for `EctoFdbRelational.SchemaTemplate` -- no live server needed.
  """
  use ExUnit.Case, async: false

  alias EctoFdbRelational.SchemaTemplate

  # `SchemaTemplate` is a single named Agent (state keyed by {database,
  # schema}), so give every test its own database/schema pair to stay
  # isolated from the others without needing `async: false` to serialize
  # more than starting the Agent itself.
  setup do
    key = "TEST_#{System.unique_integer([:positive])}"
    {:ok, database: "/FRL/#{key}", schema: "PUBLIC"}
  end

  describe "column_order/3" do
    test "returns the column order a table was declared with", %{database: db, schema: s} do
      SchemaTemplate.put_table(db, s, "item", "CREATE TABLE item (...)", ["i_id", "i_name"])
      assert SchemaTemplate.column_order(db, s, "item") == ["i_id", "i_name"]
    end

    test "returns nil for a table that was never registered", %{database: db, schema: s} do
      assert SchemaTemplate.column_order(db, s, "nonexistent") == nil
    end

    test "returns nil for a table registered without a column order (put_table/4-arity)", %{
      database: db,
      schema: s
    } do
      SchemaTemplate.put_table(db, s, "legacy", "CREATE TABLE legacy (...)")
      assert SchemaTemplate.column_order(db, s, "legacy") == nil
    end

    test "reflects the latest put_table/5 call for the same table", %{database: db, schema: s} do
      SchemaTemplate.put_table(db, s, "item", "v1", ["a", "b"])
      SchemaTemplate.put_table(db, s, "item", "v2", ["b", "a"])
      assert SchemaTemplate.column_order(db, s, "item") == ["b", "a"]
    end
  end

  describe "reorder_to_declared/3" do
    # This is the exact bug this function exists to fix: FRL binds INSERT
    # `?` parameters to a table's *declared* column position, not the
    # position of the matching column name in the statement's own column
    # list -- reproduced against a real cluster as "A value cannot be
    # assigned to a variable because the type of the value does not match
    # the type of the variable" when Ecto's (effectively alphabetical)
    # INSERT column order didn't match the migration's declared order.
    test "permutes columns and params together to match declared order" do
      # Ecto emits columns alphabetically; the table was declared i_id,
      # i_im_id, i_name, i_price, i_data.
      columns = ["i_data", "i_id", "i_im_id", "i_name", "i_price"]
      params = ["data", 1, 1, "item1", 9.99]
      declared = ["i_id", "i_im_id", "i_name", "i_price", "i_data"]

      assert SchemaTemplate.reorder_to_declared(columns, params, declared) ==
               {["i_id", "i_im_id", "i_name", "i_price", "i_data"], [1, 1, "item1", 9.99, "data"]}
    end

    test "is a no-op when the columns already match the declared order" do
      columns = ["a", "b", "c"]
      params = [1, 2, 3]

      assert SchemaTemplate.reorder_to_declared(columns, params, columns) ==
               {columns, params}
    end

    test "keeps a column absent from declared/3 after every known column, stably" do
      columns = ["extra", "a", "b"]
      params = [:extra_value, 1, 2]

      assert SchemaTemplate.reorder_to_declared(columns, params, ["a", "b"]) ==
               {["a", "b", "extra"], [1, 2, :extra_value]}
    end

    test "handles a single column" do
      assert SchemaTemplate.reorder_to_declared(["only"], [1], ["only"]) == {["only"], [1]}
    end
  end
end
