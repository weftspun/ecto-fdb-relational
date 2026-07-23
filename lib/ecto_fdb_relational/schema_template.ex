defmodule EctoFdbRelational.SchemaTemplate do
  @moduledoc """
  Accumulates `CREATE TABLE` / `CREATE INDEX` DDL fragments across a single
  `mix ecto.migrate` run and (re)materializes them as one FRL
  `CREATE SCHEMA TEMPLATE` statement.

  ## Why this exists

  Ecto's migration model is incremental: each migration file issues its own
  `CREATE TABLE`/`ALTER TABLE`/`CREATE INDEX` statements against
  already-existing server state. FRL's DDL model (see `SQL_Getting_Started.md`
  and `create-drop.yamsql` in FoundationDB/fdb-record-layer) is holistic
  instead: every table a schema will ever have is declared *inside* a single

      CREATE SCHEMA TEMPLATE <name>
          CREATE TABLE ...
          CREATE INDEX ...

  statement, and a database's schema is instantiated from that named
  template with `CREATE SCHEMA <db>/<schema> WITH TEMPLATE <name>`. There is
  no incremental `ALTER TABLE ADD COLUMN` in the dialect as verified against
  FoundationDB's own yaml-tests.

  ## The MVP strategy implemented here (and its real tradeoff)

  This `Agent` accumulates every `create table` / `create index` DDL
  fragment issued during the lifetime of the BEAM node (keyed by
  `{database, schema}`), and `EctoFdbRelational.Adapter.Connection.execute_ddl/1`
  re-issues the *entire* accumulated template as a fresh
  `CREATE SCHEMA TEMPLATE` under a new generated name, then drops and
  recreates the `/database/schema` instance to point at it.

  **This is destructive**: recreating the schema against the new template
  version means any data already stored under the old template is not
  migrated forward. It is fine for the common "run all migrations once
  against a fresh database" workflow (e.g. `mix ecto.create && mix
  ecto.migrate` in dev/test, or the test suite in this repo), but it is
  **not** a safe schema-evolution story for a database that already holds
  production data. See the README "Known gaps" section -- a real
  implementation would need to either use FRL's schema template versioning
  (if/when it grows an `ALTER SCHEMA TEMPLATE` that can add tables/indexes
  in place) or shell out to a proper online migration process. This module
  exists so `mix ecto.migrate` produces *real, verified-dialect* DDL rather
  than pretending incremental `ALTER TABLE` works when it doesn't.
  """

  use Agent

  defstruct tables: %{}, indexes: %{}, version: 0

  def start_link(_opts \\ []) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker
    }
  end

  @doc """
  Registers (or replaces) a table's DDL fragment for `{database, schema}`,
  along with its declared column order (`column_order`, a list of column-name strings in the order the `CREATE TABLE` columns were declared) -- see
  `column_order/3` for why that order needs to be kept around separately
  from the fragment text.
  """
  def put_table(database, schema, table_name, ddl_fragment, column_order \\ nil) do
    ensure_started()

    Agent.update(__MODULE__, fn state ->
      key = {database, schema}
      entry = Map.get(state, key, %__MODULE__{})

      tables =
        Map.put(entry.tables, table_name, %{fragment: ddl_fragment, columns: column_order})

      Map.put(state, key, %{entry | tables: tables, version: entry.version + 1})
    end)
  end

  @doc """
  The column order `table_name` was declared with (a list of column-name strings),
  or `nil` if this table isn't known.

  `EctoFdbRelational.Protocol.handle_execute/4` needs this: FRL's
  `PreparedStatement` parameter binding turns out to bind each `?` to the
  table's *declared* column position, not the position of the matching
  column name in the `INSERT INTO tbl (a, b, c) VALUES (?, ?, ?)` column
  list actually sent -- despite the column list being present and
  correctly named. Ecto's own column list order for an insert follows
  `Ecto.Schema`'s (effectively alphabetical, via a `Map`-backed changeset)
  field order, which routinely differs from a migration's declared column
  order, so without reordering to match, values silently bind to the wrong
  columns whenever the two orders differ (and simply error out when the
  types at the swapped positions don't happen to match, as happened here).
  """
  def column_order(database, schema, table_name) do
    ensure_started()

    Agent.get(__MODULE__, fn state ->
      case Map.get(state, {database, schema}, %__MODULE__{}).tables[table_name] do
        %{columns: columns} -> columns
        _ -> nil
      end
    end)
  end

  @doc """
  Permutes an INSERT statement's own column list (`columns`) and its bound
  `params` (given in that same order) to match `declared` -- see
  `column_order/3`'s moduledoc for why. A column absent from `declared`
  (shouldn't happen for a table this module actually created, but keeps
  this total rather than raising) sorts after every known column, in its
  original relative order.

      iex> EctoFdbRelational.SchemaTemplate.reorder_to_declared(
      ...>   ["i_data", "i_id", "i_price"],
      ...>   ["hi", 1, 9.99],
      ...>   ["i_id", "i_price", "i_data"]
      ...> )
      {["i_id", "i_price", "i_data"], [1, 9.99, "hi"]}
  """
  @spec reorder_to_declared([String.t()], [term()], [String.t()]) ::
          {[String.t()], [term()]}
  def reorder_to_declared(columns, params, declared) do
    rank = declared |> Enum.with_index() |> Map.new()
    unranked = map_size(rank)

    order =
      columns
      |> Enum.with_index()
      |> Enum.sort_by(fn {col, _i} -> Map.get(rank, col, unranked) end)
      |> Enum.map(fn {_col, i} -> i end)

    {Enum.map(order, &Enum.at(columns, &1)), Enum.map(order, &Enum.at(params, &1))}
  end

  @doc "Removes a table (used by `drop table(...)`)."
  def delete_table(database, schema, table_name) do
    ensure_started()

    Agent.update(__MODULE__, fn state ->
      key = {database, schema}
      entry = Map.get(state, key, %__MODULE__{})
      tables = Map.delete(entry.tables, table_name)
      Map.put(state, key, %{entry | tables: tables, version: entry.version + 1})
    end)
  end

  @doc "Registers (or replaces) an index's DDL fragment for `{database, schema}`."
  def put_index(database, schema, index_name, ddl_fragment) do
    ensure_started()

    Agent.update(__MODULE__, fn state ->
      key = {database, schema}
      entry = Map.get(state, key, %__MODULE__{})
      indexes = Map.put(entry.indexes, index_name, ddl_fragment)
      Map.put(state, key, %{entry | indexes: indexes, version: entry.version + 1})
    end)
  end

  def delete_index(database, schema, index_name) do
    ensure_started()

    Agent.update(__MODULE__, fn state ->
      key = {database, schema}
      entry = Map.get(state, key, %__MODULE__{})
      indexes = Map.delete(entry.indexes, index_name)
      Map.put(state, key, %{entry | indexes: indexes, version: entry.version + 1})
    end)
  end

  @doc """
  Returns `{template_name, ddl_fragments, version}` reflecting everything
  registered so far for `{database, schema}`, where `ddl_fragments` is the
  ordered list of `CREATE TABLE ...` / `CREATE INDEX ...` clauses to embed in
  a `CREATE SCHEMA TEMPLATE` statement.
  """
  def snapshot(database, schema) do
    ensure_started()

    Agent.get(__MODULE__, fn state ->
      entry = Map.get(state, {database, schema}, %__MODULE__{})
      table_fragments = entry.tables |> Map.values() |> Enum.map(& &1.fragment)
      fragments = table_fragments ++ Map.values(entry.indexes)
      name = template_name(database, schema, entry.version)
      {name, fragments, entry.version}
    end)
  end

  defp template_name(database, schema, version) do
    slug =
      "#{database}_#{schema}"
      |> String.replace(~r/[^A-Za-z0-9_]/, "_")
      |> String.trim("_")

    "ecto_fdb_relational_#{slug}_v#{version}"
  end

  defp ensure_started do
    case Process.whereis(__MODULE__) do
      nil -> start_link()
      _pid -> :ok
    end
  end
end
