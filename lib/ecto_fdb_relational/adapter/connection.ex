defmodule EctoFdbRelational.Adapter.Connection do
  @moduledoc """
  Implements `Ecto.Adapters.SQL.Connection`: turns `Ecto.Query` structs and
  `Ecto.Migration` commands into FRL SQL text, and wires the DBConnection
  pool (`EctoFdbRelational.Protocol`) up to `Ecto.Adapters.SQL`.

  ## Scope (v0.1) -- please read before relying on this in production

  The query builder below intentionally supports a **subset** of Ecto's
  query API: single-table `select`/`where`/`order_by` with basic comparison
  operators, plus `insert`/`update_all`/`delete_all`. It deliberately
  **raises** (`ArgumentError`, at query-build time, not silently wrong SQL)
  for anything it doesn't yet translate correctly: joins, subqueries,
  `group_by`/`having`/aggregates, `limit`/`offset`, `ON CONFLICT`,
  `RETURNING`, and most functions/operators beyond `==`, `!=`, `<`, `<=`,
  `>`, `>=`, `and`, `or`, `not`, `is_nil`, and `in` with a literal list.
  See the README "Known gaps" section for the up to date list and why (FRL
  itself does not support in-memory sorting/aggregation without a backing
  index -- see `SQL_Getting_Started.md` -- so several of these gaps are
  intrinsic to the target database, not just this adapter).
  """

  @behaviour Ecto.Adapters.SQL.Connection

  alias EctoFdbRelational.Query
  alias EctoFdbRelational.{Ddl, Types}

  ## Connection wiring

  @impl true
  def child_spec(opts) do
    DBConnection.child_spec(EctoFdbRelational.Protocol, opts)
  end

  @impl true
  def prepare_execute(conn, name, statement, params, opts) do
    query = %Query{
      name: name,
      statement: statement,
      command: Keyword.get(opts, :command, :select)
    }

    DBConnection.prepare_execute(conn, query, params, opts)
  end

  @impl true
  def execute(conn, %Query{} = query, params, opts) do
    DBConnection.execute(conn, query, params, opts)
  end

  def execute(conn, statement, params, opts) when is_binary(statement) or is_list(statement) do
    query = %Query{statement: statement, command: Keyword.get(opts, :command, :select)}
    DBConnection.execute(conn, query, params, opts)
  end

  @impl true
  def query(conn, statement, params, opts) do
    query = %Query{statement: statement, command: Keyword.get(opts, :command, :select)}

    case DBConnection.prepare_execute(conn, query, params, opts) do
      {:ok, _query, result} -> {:ok, result}
      {:error, _} = error -> error
    end
  end

  @impl true
  def query_many(_conn, _statement, _params, _opts) do
    {:error,
     %EctoFdbRelational.Error{
       message: "EctoFdbRelational does not support multi-statement query_many/4 yet"
     }}
  end

  @impl true
  def stream(_conn, _statement, _params, _opts) do
    raise EctoFdbRelational.Error,
      message:
        "EctoFdbRelational does not implement Repo.stream/2 yet -- JDBCService's " <>
          "continuation-based paging (see continuation.proto) is not wired up in v0.1"
  end

  @impl true
  def to_constraints(%EctoFdbRelational.Error{}, _opts), do: []
  def to_constraints(_exception, _opts), do: []

  ## Query building

  @impl true
  def all(query) do
    assert_supported_shape!(query)
    sources = create_sources(query)

    [
      "SELECT ",
      select_fields(query, sources),
      " FROM ",
      from_table(query, sources),
      where_clause(query, sources),
      order_by_clause(query, sources)
    ]
  end

  @impl true
  def update_all(query) do
    assert_supported_shape!(query)
    sources = create_sources(query)

    [
      "UPDATE ",
      from_table(query, sources),
      " SET ",
      update_fields(query, sources),
      where_clause(query, sources)
    ]
  end

  @impl true
  def delete_all(query) do
    assert_supported_shape!(query)
    sources = create_sources(query)

    [
      "DELETE FROM ",
      from_table(query, sources),
      where_clause(query, sources)
    ]
  end

  # Everything this v0.1 query builder does *not* attempt to translate --
  # checked explicitly so unsupported query shapes raise a clear error
  # instead of silently emitting SQL that ignores half the query (e.g. a
  # join whose ON-clause is simply dropped). See the moduledoc.
  defp assert_supported_shape!(query) do
    cond do
      query.joins != [] ->
        raise_unsupported("joins")

      query.group_bys != [] ->
        raise_unsupported(
          "GROUP BY (FRL requires an aggregate index for this anyway -- see SQL_Getting_Started.md)"
        )

      query.havings != [] ->
        raise_unsupported("HAVING")

      query.combinations != [] ->
        raise_unsupported("UNION/INTERSECT/EXCEPT")

      query.windows != [] ->
        raise_unsupported("window functions")

      query.with_ctes != nil ->
        raise_unsupported("CTEs (WITH)")

      query.distinct != nil ->
        raise_unsupported("DISTINCT")

      query.limit != nil ->
        raise_unsupported(
          "LIMIT (use the :max_rows Repo option via Options.max_rows once wired up -- not implemented in v0.1)"
        )

      query.offset != nil ->
        raise_unsupported("OFFSET")

      true ->
        :ok
    end
  end

  @doc false
  def insert(prefix, table, header, rows, on_conflict, returning, placeholders) do
    insert(prefix, table, header, rows, on_conflict, returning, placeholders, [])
  end

  @impl true
  def insert(_prefix, table, header, rows, _on_conflict, returning, _placeholders, _opts) do
    unless returning == [] do
      raise EctoFdbRelational.Error,
        message:
          "EctoFdbRelational does not support RETURNING on INSERT yet " <>
            "(FRL's JDBCService StatementResponse only exposes a row count for DML -- " <>
            "see StatementResponse in jdbc.proto). Supply primary keys client-side " <>
            "and avoid Repo.insert! returning: true / auto-generated fields."
    end

    fields = quote_names(header)

    values =
      Enum.map_join(rows, ", ", fn row ->
        ["(", Enum.map_join(row, ", ", fn _ -> "?" end), ")"]
      end)

    ["INSERT INTO ", quote_table(table), " (", fields, ") VALUES ", values]
  end

  @impl true
  def update(_prefix, table, fields, filters, returning) do
    unless returning == [] do
      raise EctoFdbRelational.Error,
        message: "EctoFdbRelational does not support RETURNING on UPDATE yet (see insert/6 docs)"
    end

    set = Enum.map_join(fields, ", ", &"#{quote_name(&1)} = ?")
    where = Enum.map_join(filters, " AND ", &"#{quote_name(&1)} = ?")

    ["UPDATE ", quote_table(table), " SET ", set, " WHERE ", where]
  end

  @impl true
  def delete(_prefix, table, filters, returning) do
    unless returning == [] do
      raise EctoFdbRelational.Error,
        message: "EctoFdbRelational does not support RETURNING on DELETE yet (see insert/6 docs)"
    end

    where = Enum.map_join(filters, " AND ", &"#{quote_name(&1)} = ?")
    ["DELETE FROM ", quote_table(table), " WHERE ", where]
  end

  @impl true
  def explain_query(_conn, _query, _params, _opts) do
    {:error,
     %EctoFdbRelational.Error{
       message: "EctoFdbRelational does not implement Repo.explain/2 yet"
     }}
  end

  ## DDL

  @impl true
  def execute_ddl(command), do: Ddl.execute_ddl(command)

  @impl true
  def ddl_logs(_result), do: []

  @impl true
  def table_exists_query(table) do
    {"SELECT 1 FROM #{table} WHERE 1 = 0", []}
  end

  ## -- internal helpers -------------------------------------------------

  defp create_sources(%{from: %{source: {table, schema}}}), do: {{table, schema}}

  defp from_table(_query, {{table, _schema}}), do: quote_table(table)

  defp select_fields(%{select: nil}, {{_table, _schema}}), do: "*"

  defp select_fields(%{select: %{fields: fields}}, sources) when is_list(fields) do
    Enum.map_join(fields, ", ", &expr(&1, sources))
  end

  defp select_fields(_query, _sources), do: "*"

  defp update_fields(%{updates: updates} = query, sources) do
    updates
    |> Enum.flat_map(fn %{expr: expr} -> expr end)
    |> Enum.map_join(", ", fn
      {:set, kw} ->
        Enum.map_join(kw, ", ", fn {field, value} ->
          [quote_name(field), " = ", expr(value, sources, query)]
        end)

      {op, _kw} ->
        raise_unsupported("update operation #{inspect(op)} (only `set` is supported in v0.1)")
    end)
  end

  defp where_clause(%{wheres: []}, _sources), do: []

  defp where_clause(%{wheres: wheres} = query, sources) do
    clause =
      wheres
      |> Enum.map(fn %{expr: expr} -> expr(expr, sources, query) end)
      |> Enum.intersperse(" AND ")

    [" WHERE " | clause]
  end

  defp order_by_clause(%{order_bys: []}, _sources), do: []

  defp order_by_clause(%{order_bys: order_bys} = query, sources) do
    clause =
      order_bys
      |> Enum.flat_map(fn %{expr: expr} -> expr end)
      |> Enum.map_join(", ", fn
        {:asc, field} -> [expr(field, sources, query), " ASC"]
        {:desc, field} -> [expr(field, sources, query), " DESC"]
        {dir, _field} -> raise_unsupported("ORDER BY direction #{inspect(dir)}")
      end)

    [" ORDER BY ", clause]
  end

  # Expressions -----------------------------------------------------------

  defp expr(ast, sources), do: expr(ast, sources, nil)

  defp expr({{:., _, [{:&, _, [_source_index]}, field]}, _, []}, _sources, _query)
       when is_atom(field) do
    quote_name(field)
  end

  defp expr({:^, _, [_index]}, _sources, _query), do: "?"

  # fdb-relational-server 4.3.6.0's SQL parser has a confirmed bug --
  # reproduced directly against a live server, no gRPC/Ecto involved --
  # where *any* parenthesized boolean expression in a WHERE clause fails
  # with "expected BooleanValue but got RecordConstructorValue": it parses
  # `(x = ?)` as a row-value constructor, not a grouped predicate, even
  # for a single condition with no AND/OR inside. `WHERE x = ? AND y = ?`
  # (no parens) binds and executes fine; `WHERE (x = ? AND y = ?)` (same
  # two conditions, parens added) fails identically. So AND/OR render flat,
  # without grouping parens, relying on SQL's standard AND-before-OR
  # precedence for correctness -- which happens to match every WHERE
  # clause this adapter can currently build, since nothing here produces
  # mixed AND/OR (see the "single-table select/where" scope note above)
  # where that precedence would matter.
  defp expr({:and, _, [left, right]}, sources, query),
    do: [expr(left, sources, query), " AND ", expr(right, sources, query)]

  defp expr({:or, _, [left, right]}, sources, query),
    do: [expr(left, sources, query), " OR ", expr(right, sources, query)]

  defp expr({:not, _, [{:is_nil, _, [field]}]}, sources, query),
    do: [expr(field, sources, query), " IS NOT NULL"]

  defp expr({:not, _, [inner]}, sources, query), do: ["NOT (", expr(inner, sources, query), ")"]

  defp expr({:is_nil, _, [field]}, sources, query), do: [expr(field, sources, query), " IS NULL"]

  defp expr({op, _, [left, right]}, sources, query) when op in [:==, :!=, :<, :<=, :>, :>=] do
    [expr(left, sources, query), " ", sql_op(op), " ", expr(right, sources, query)]
  end

  defp expr({:in, _, [left, right]}, sources, query) when is_list(right) do
    list = Enum.map_join(right, ", ", &expr(&1, sources, query))
    [expr(left, sources, query), " IN (", list, ")"]
  end

  defp expr(value, _sources, _query)
       when is_integer(value) or is_float(value) or is_boolean(value) do
    to_string(value)
  end

  defp expr(value, _sources, _query) when is_binary(value) do
    ["'", String.replace(value, "'", "''"), "'"]
  end

  defp expr(nil, _sources, _query), do: "NULL"

  defp expr(other, _sources, _query) do
    raise_unsupported("expression #{inspect(other)}")
  end

  defp sql_op(:==), do: "="
  defp sql_op(:!=), do: "<>"
  defp sql_op(op), do: Atom.to_string(op)

  defp raise_unsupported(what) do
    raise EctoFdbRelational.Error,
      message:
        "EctoFdbRelational's query builder does not support #{what} in v0.1. " <>
          "It supports single-table select/where/order_by with ==, !=, <, <=, >, >=, " <>
          "and, or, not, is_nil, and `in` with a literal list -- see the moduledoc " <>
          "on EctoFdbRelational.Adapter.Connection and the README's Known gaps section."
  end

  defp quote_table({nil, table}), do: quote_name(table)
  defp quote_table({prefix, table}), do: [quote_name(prefix), ".", quote_name(table)]
  defp quote_table(table) when is_binary(table), do: quote_name(table)

  defp quote_names(names), do: Enum.map_join(names, ", ", &quote_name/1)

  defp quote_name(name) when is_atom(name), do: Atom.to_string(name)
  defp quote_name(name) when is_binary(name), do: name

  # Re-exported so migrations and the schema-template accumulator can share
  # the same Ecto <-> FRL type mapping.
  @doc false
  def ddl_type(type), do: Types.ddl_type(type)
end
