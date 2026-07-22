defmodule EctoFdbRelational do
  @moduledoc """
  An `Ecto` adapter for FoundationDB Record Layer's Relational Layer (FRL).

  Start here:

    * `EctoFdbRelational.Adapter` - the `Ecto.Adapter` to put in your `Repo`'s
      `use Ecto.Repo, adapter: EctoFdbRelational.Adapter`, plus config docs.
    * `EctoFdbRelational.Adapter.Connection` - what subset of Ecto's query
      API and migrations are actually implemented in v0.1 (please read this
      before relying on the adapter -- it raises clear errors for
      unsupported query shapes rather than emitting silently wrong SQL).
    * `EctoFdbRelational.Protocol` - the `DBConnection` driver that speaks
      gRPC directly to `fdb-relational-server`'s `JDBCService`.
    * the project README - what FRL is, the architecture decision (gRPC,
      not JDBC/a JVM/a Rust NIF) and why, and the full "Known gaps" list.
  """
end
