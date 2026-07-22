# Changelog

## v0.1.0

Initial release.

* `EctoFdbRelational.Adapter`: an `Ecto.Adapter` built on `Ecto.Adapters.SQL`,
  talking gRPC directly to `fdb-relational-server`'s `JDBCService` (see
  `ADR.md`). No JDBC, no embedded JVM, no NIF.
* Real, vendored `.proto` files from `FoundationDB/fdb-record-layer`'s
  `fdb-relational-grpc` module, compiled with `protoc`/`protoc-gen-elixir`
  into working Elixir gRPC client stubs (`lib/ecto_fdb_relational/grpc/`).
* Query builder (`EctoFdbRelational.Adapter.Connection`) supporting
  single-table `select`/`where`/`order_by`/`insert`/`update_all`/`delete_all`;
  raises clear errors for unsupported shapes (joins, aggregates, limit/offset,
  RETURNING, etc.) instead of emitting wrong SQL. See README "Known gaps".
  Covered by unit tests against `Ecto.Query.Planner` output (no live server
  needed).
  * `mix ecto.migrate` support for `create table`/`drop table`/`create
    index`/`drop index`, translated to FRL's schema-template DDL dialect via
    `EctoFdbRelational.Ddl` + `EctoFdbRelational.SchemaTemplate`. Documented
    as destructive/lossy across migrations in v0.1 -- FRL's DDL model is
    holistic, Ecto's is incremental, and this is the honest tradeoff of
    bridging the two right now.
* An integration test suite (`test/ecto_fdb_relational/integration_test.exs`)
  that exercises real CRUD through `Ecto.Repo` against a live
  `fdb-relational-server`, skipped gracefully (not silently) without one.
  Not run against a live server as part of building v0.1 -- see README.
