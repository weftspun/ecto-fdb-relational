defmodule EctoFdbRelational.Ddl do
  @moduledoc """
  Translates `Ecto.Adapter.Migration.command()` values into FRL's own DDL
  dialect (verified against `SQL_Getting_Started.md` and
  `yaml-tests/src/test/resources/create-drop.yamsql` in
  FoundationDB/fdb-record-layer -- **not** standard SQL: `STRING` not
  `VARCHAR`, tables/indexes declared *inside* `CREATE SCHEMA TEMPLATE`, no
  `ALTER TABLE`).

  See `EctoFdbRelational.SchemaTemplate` for why this accumulates state and
  re-emits the whole template on every call, and the README's "Known gaps"
  section for the resulting (real, not hidden) limitation: this is not a
  safe schema-evolution story for a database that already holds data.

  ## Where `database`/`relational_schema` come from

  `Ecto.Adapters.SQL.Connection.execute_ddl/1` is a pure function of the
  migration command alone -- it is not handed the repo's config. FRL's
  `CREATE DATABASE /path`/`CREATE SCHEMA /path/name WITH TEMPLATE ...`
  statements need that path embedded as a literal in the SQL text, though,
  so `EctoFdbRelational.Protocol.connect/1` stashes
  `{database, relational_schema}` in `:persistent_term` (see there) the
  moment a connection is established -- which always happens before any
  migration can run. This means, as documented in the README, **v0.1 only
  supports migrating one FRL-backed database per BEAM node at a time**.
  """

  alias EctoFdbRelational.{Error, SchemaTemplate, Types}

  @persistent_term_key {EctoFdbRelational, :ddl_context}

  @doc false
  def put_ddl_context(database, relational_schema) do
    :persistent_term.put(@persistent_term_key, {database, relational_schema})
  end

  defp ddl_context! do
    case :persistent_term.get(@persistent_term_key, nil) do
      {database, schema} ->
        {database, schema}

      nil ->
        raise Error,
          message:
            "EctoFdbRelational could not determine the target FRL database/schema for DDL. " <>
              "This is set the first time a connection is established (see " <>
              "EctoFdbRelational.Protocol.connect/1) -- make sure the Repo has connected " <>
              "(e.g. run `mix ecto.create` / open a connection) before running migrations."
    end
  end

  @doc "Implements `Ecto.Adapters.SQL.Connection.execute_ddl/1`."
  def execute_ddl({:create, %Ecto.Migration.Table{} = table, columns}) do
    put_table_and_rematerialize(table, columns)
  end

  def execute_ddl({:create_if_not_exists, %Ecto.Migration.Table{} = table, columns}) do
    put_table_and_rematerialize(table, columns)
  end

  def execute_ddl({:drop, %Ecto.Migration.Table{name: name}, _mode}) do
    {database, schema} = ddl_context!()
    SchemaTemplate.delete_table(database, schema, to_string(name))
    rematerialize(database, schema)
  end

  def execute_ddl({:drop_if_exists, %Ecto.Migration.Table{name: name}, _mode}) do
    {database, schema} = ddl_context!()
    SchemaTemplate.delete_table(database, schema, to_string(name))
    rematerialize(database, schema)
  end

  def execute_ddl({:create, %Ecto.Migration.Index{} = index}) do
    put_index_and_rematerialize(index)
  end

  def execute_ddl({:create_if_not_exists, %Ecto.Migration.Index{} = index}) do
    put_index_and_rematerialize(index)
  end

  def execute_ddl({:drop, %Ecto.Migration.Index{name: name}, _mode}) do
    {database, schema} = ddl_context!()
    SchemaTemplate.delete_index(database, schema, to_string(name))
    rematerialize(database, schema)
  end

  def execute_ddl({:drop_if_exists, %Ecto.Migration.Index{name: name}, _mode}) do
    {database, schema} = ddl_context!()
    SchemaTemplate.delete_index(database, schema, to_string(name))
    rematerialize(database, schema)
  end

  def execute_ddl(command) do
    raise Error,
      message:
        "EctoFdbRelational does not translate #{inspect(command)} yet. v0.1 only supports " <>
          "`create table`, `create table (create_if_not_exists)`, `drop table`, " <>
          "`create index`, and `drop index` -- notably *not* `alter table` (FRL's DDL " <>
          "dialect has no incremental ALTER; see the EctoFdbRelational.SchemaTemplate " <>
          "moduledoc and the README's Known gaps section)."
  end

  ## -- table / index DDL fragment rendering -----------------------------

  defp put_table_and_rematerialize(table, columns) do
    {database, schema} = ddl_context!()
    fragment = render_table(table, columns)
    column_order = for {:add, col_name, _type, _opts} <- columns, do: to_string(col_name)
    SchemaTemplate.put_table(database, schema, to_string(table.name), fragment, column_order)
    rematerialize(database, schema)
  end

  defp put_index_and_rematerialize(index) do
    {database, schema} = ddl_context!()
    fragment = render_index(index)
    SchemaTemplate.put_index(database, schema, to_string(index.name), fragment)
    rematerialize(database, schema)
  end

  defp render_table(%Ecto.Migration.Table{name: name}, columns) do
    pk_fields =
      for {:add, col_name, _type, opts} <- columns, Keyword.get(opts, :primary_key, false) do
        to_string(col_name)
      end

    column_defs =
      for {:add, col_name, type, _opts} <- columns do
        "#{col_name} #{Types.ddl_type(type)}"
      end

    pk_clause =
      case pk_fields do
        [] -> ""
        fields -> ", PRIMARY KEY(#{Enum.join(fields, ", ")})"
      end

    "CREATE TABLE #{name} (#{Enum.join(column_defs, ", ")}#{pk_clause})"
  end

  defp render_index(%Ecto.Migration.Index{name: name, table: table, columns: columns}) do
    cols = Enum.map_join(columns, ", ", &to_string/1)
    "CREATE INDEX #{name} AS SELECT #{cols} FROM #{table} ORDER BY #{cols}"
  end

  # Re-issues the entire accumulated schema template for {database, schema}.
  #
  # Only statement forms actually verified against FoundationDB/fdb-record-layer's
  # own yaml-tests (create-drop.yamsql) are used here: `DROP DATABASE IF EXISTS`
  # and `DROP SCHEMA TEMPLATE IF EXISTS` are confirmed; a finer-grained
  # "drop just this schema, keep the database" statement was *not* found in
  # the verified docs/tests at the time this was written, so this drops and
  # recreates the whole database on every DDL command -- more destructive
  # than the SchemaTemplate moduledoc's original "drop the schema" framing,
  # and called out explicitly in the README's Known gaps section. Each
  # rematerialization also mints a new, uniquely-named schema template
  # (`ecto_fdb_relational_..._vN`) without dropping the previous one, so
  # old template versions accumulate in FRL's catalog -- a known, minor
  # leak documented in the README rather than silently ignored.
  defp rematerialize(database, schema) do
    {template_name, fragments, _version} = SchemaTemplate.snapshot(database, schema)

    template_body = Enum.join(fragments, " ")

    [
      "DROP DATABASE IF EXISTS #{database}",
      "CREATE SCHEMA TEMPLATE #{template_name} #{template_body}",
      "CREATE DATABASE #{database}",
      "CREATE SCHEMA #{database}/#{schema} WITH TEMPLATE #{template_name}"
    ]
  end
end
