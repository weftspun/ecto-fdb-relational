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

  @doc "Registers (or replaces) a table's DDL fragment for `{database, schema}`."
  def put_table(database, schema, table_name, ddl_fragment) do
    ensure_started()

    Agent.update(__MODULE__, fn state ->
      key = {database, schema}
      entry = Map.get(state, key, %__MODULE__{})
      tables = Map.put(entry.tables, table_name, ddl_fragment)
      Map.put(state, key, %{entry | tables: tables, version: entry.version + 1})
    end)
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
      fragments = Map.values(entry.tables) ++ Map.values(entry.indexes)
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
