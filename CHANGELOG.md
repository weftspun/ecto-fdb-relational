# Changelog

## v0.3.0

Real `Repo.transaction/2` support -- multiple statements now batch into one FDB
transaction/commit instead of autocommitting each individually (measured ~3x faster
for a bulk-write workload; FDB's own per-statement commit latency dominates this
transport's total cost, far more than the JNI/Rust/Elixir plumbing around it -- see
`EctoFdbRelational.Protocol`'s "Transactions" moduledoc section):

* `EctoFdbRelational.Native.begin/3`, `execute_in_transaction/2`, `commit/1` and
  `rollback/1`: a real, autocommit-disabled `RelationalConnection` (the same JDBC
  interface behind FRL's documented `jdbc:embed:` driver), opened via `FRL`'s own
  internal `RelationalDriver` rather than its always-autocommit `FRL.execute`
  convenience wrapper.
* `native/frl_bridge/Bridge.java` builds `StatementResponse`/`ResultSet` protobuf
  messages itself for the in-transaction path (`FRL.execute`'s own marshalling isn't
  reusable outside its own per-call connection lifecycle) -- covers the same v0.1
  scalar scope `EctoFdbRelational.Types` already documents (long/string/boolean/
  double/binary/null), verified byte-for-byte against `FRL.execute`'s own output
  through the real `Types.decode_column/1` decoder.
* Both reads and writes work inside a transaction (read-your-writes on uncommitted
  data, real isolation from other connections until commit, full rollback). Catalog-
  level DDL (`CREATE`/`DROP DATABASE`/`SCHEMA`/`SCHEMA TEMPLATE`) is **not** supported
  inside a transaction -- raises a clear error rather than silently running against
  the wrong database/schema; not a real-world gap since `supports_ddl_transaction?/0`
  is already `false` and migrations never run inside `Repo.transaction/2` here anyway.

## v0.2.0

Replaces the gRPC transport outright with an embedded-JVM one (see ADR 0003):

* `EctoFdbRelational.Native`: a Rustler NIF (`native/ecto_fdb_relational_nif`)
  embedding a JVM via `jni`'s invocation API, calling
  `com.apple.foundationdb.relational.server.FRL` directly through
  `native/frl_bridge`'s one Java class. No separately-managed
  `fdb-relational-server` process, no gRPC, anywhere.
* The wire *shape* is unchanged: `EctoFdbRelational.Native` carries the same
  `grpc.relational.jdbc.v1.{StatementRequest,StatementResponse}` protobuf
  bytes the old gRPC transport did, just over JNI instead of gRPC/HTTP2 --
  `EctoFdbRelational.Types`/`Query`/DDL-catalog-routing logic is unchanged.
  `lib/ecto_fdb_relational/grpc/` moved to `lib/ecto_fdb_relational/proto/`
  with the generated `GRPC.Service`/`GRPC.Stub` code removed (plain protobuf
  message codecs only).
* `Repo` config changed from `hostname`/`port` (the gRPC address) to
  `cluster_file` (the FoundationDB cluster file path).
* The `{:grpc}` dependency is gone; `{:rustler}` was added. Building this
  adapter now requires a JDK and a Rust toolchain -- see the README.
* `spike/jvm_embed` (ADR 0002's de-risking spike) is removed; it served its
  purpose and `native/frl_bridge` is its real, non-throwaway successor.

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
