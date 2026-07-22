defmodule EctoFdbRelational.Adapter.ConnectionTest do
  @moduledoc """
  Unit tests for the FRL SQL builder. These do **not** require a live
  `fdb-relational-server`/FoundationDB cluster: they only exercise
  `Ecto.Query.Planner.plan/normalize` (pure query normalization) and then
  `EctoFdbRelational.Adapter.Connection`'s SQL rendering, asserting on the
  generated SQL text. See `test/ecto_fdb_relational/integration_test.exs`
  for the tests that need a real server and are skipped without one.
  """
  use ExUnit.Case, async: true

  import Ecto.Query

  alias EctoFdbRelational.Adapter
  alias EctoFdbRelational.Test.Post

  defp plan(query, operation) do
    {query, _params, _key} = Ecto.Query.Planner.plan(query, operation, Adapter)
    {query, _select} = Ecto.Query.Planner.normalize(query, operation, Adapter, 0)
    query
  end

  defp sql(query, operation \\ :all) do
    query = plan(query, operation)

    iodata =
      case operation do
        :all -> Adapter.Connection.all(query)
        :update_all -> Adapter.Connection.update_all(query)
        :delete_all -> Adapter.Connection.delete_all(query)
      end

    IO.iodata_to_binary(iodata)
  end

  test "all/1 renders a plain select *" do
    query = from(p in Post)
    assert sql(query) == "SELECT * FROM posts"
  end

  test "all/1 renders selected fields, a comparison where, and order_by" do
    query =
      from(p in Post,
        where: p.views > ^10,
        select: p.title,
        order_by: [asc: p.title]
      )

    assert sql(query) == "SELECT title FROM posts WHERE views > ? ORDER BY title ASC"
  end

  test "all/1 renders and/or/is_nil" do
    query =
      from(p in Post,
        where: p.published == true and is_nil(p.title),
        select: p.id
      )

    assert sql(query) == "SELECT id FROM posts WHERE published = true AND title IS NULL"
  end

  test "all/1 renders `a and b or c` without grouping parens, AND still binding tighter" do
    # Elixir's own `and`/`or` precedence (`and` binds tighter, matching
    # standard SQL) puts this source expression's implicit grouping at
    # {:or, [{:and, [a, b]}, c]} -- see EctoFdbRelational.Adapter.Connection's
    # expr/3 moduledoc comment on :and/:or for why no grouping parens are
    # emitted (fdb-relational-server rejects them entirely). Rendering flat
    # relies on FRL's own SQL parser applying the same AND-before-OR
    # precedence Elixir already used to build this AST, so the meaning
    # survives the round trip through unparenthesized text.
    query =
      from(p in Post,
        where: p.published == true and p.views > ^10 or is_nil(p.title),
        select: p.id
      )

    assert sql(query) ==
             "SELECT id FROM posts WHERE published = true AND views > ? OR title IS NULL"
  end

  test "all/1 renders `a or b and c` without grouping parens, AND still binding tighter" do
    query =
      from(p in Post,
        where: p.published == true or p.views > ^10 and is_nil(p.title),
        select: p.id
      )

    assert sql(query) ==
             "SELECT id FROM posts WHERE published = true OR views > ? AND title IS NULL"
  end

  test "all/1 renders in/2 with a literal list" do
    query = from(p in Post, where: p.id in [1, 2, 3], select: p.id)
    assert sql(query) == "SELECT id FROM posts WHERE id IN (1, 2, 3)"
  end

  test "update_all/1 renders SET ... WHERE ..." do
    query = from(p in Post, where: p.id == ^1, update: [set: [views: ^5]])
    assert sql(query, :update_all) == "UPDATE posts SET views = ? WHERE id = ?"
  end

  test "delete_all/1 renders DELETE FROM ... WHERE ..." do
    query = from(p in Post, where: p.id == ^1)
    assert sql(query, :delete_all) == "DELETE FROM posts WHERE id = ?"
  end

  test "insert/7 renders INSERT INTO ... VALUES (...)" do
    sql =
      Adapter.Connection.insert(
        nil,
        "posts",
        [:id, :title],
        [[:id, :title]],
        {:raise, [], []},
        [],
        []
      )
      |> IO.iodata_to_binary()

    assert sql == "INSERT INTO posts (id, title) VALUES (?, ?)"
  end

  test "insert/7 raises a clear error when RETURNING is requested" do
    assert_raise EctoFdbRelational.Error, ~r/RETURNING/, fn ->
      Adapter.Connection.insert(nil, "posts", [:id], [[:id]], {:raise, [], []}, [:id], [])
    end
  end

  test "a join query raises a clear 'not supported' error instead of silently wrong SQL" do
    query = from(p in Post, join: p2 in Post, on: p2.id == p.id, select: p.id)

    assert_raise EctoFdbRelational.Error, ~r/joins/, fn ->
      sql(query)
    end
  end

  test "a limit raises a clear 'not supported' error instead of being silently ignored" do
    query = from(p in Post, limit: 1)

    assert_raise EctoFdbRelational.Error, ~r/LIMIT/, fn ->
      sql(query)
    end
  end
end
