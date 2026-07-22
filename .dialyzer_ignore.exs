[
  # `use Ecto.Adapters.SQL, driver: :ecto_fdb_relational` (EctoFdbRelational.Adapter)
  # generates a `rollback/2` that calls `Ecto.Repo.rollback/1`, which -- by
  # design, in every Ecto adapter -- always `throw`s to unwind out of
  # `Repo.transaction/2` rather than ever returning normally. Dialyzer flags
  # that as `no_return` on code this adapter doesn't author or control (it
  # comes from Ecto.Adapters.SQL's own macro expansion), so it's ignored here
  # rather than worked around.
  {"lib/ecto_fdb_relational/adapter.ex", :no_return},

  # `stream/4` (Repo.stream/2 -- not implemented in v0.1, see its own doc) and
  # `raise_unsupported/1` (the query builder's catch-all for unsupported query
  # shapes, see the moduledoc's "Scope" section) both always raise by design,
  # same as the entries above -- an inline `@dialyzer {:no_return, ...}`
  # module attribute did not suppress these two for reasons not fully
  # understood, so they're listed here instead, where it's confirmed to work.
  {"lib/ecto_fdb_relational/adapter/connection.ex", :no_return}
]
