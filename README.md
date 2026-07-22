# EctoFdbRelational

An [`Ecto`](https://hexdocs.pm/ecto) adapter for
[FoundationDB Record Layer](https://github.com/FoundationDB/fdb-record-layer)'s
**Relational Layer (FRL)** -- a SQL layer on top of FDB's Record Layer,
served by `fdb-relational-server` and spoken to here over gRPC directly
(no JDBC, no embedded JVM, no NIF -- see [`ADR.md`](ADR.md) for why).

> **Status: v0.1, pre-1.0.** This adapter implements enough of Ecto's query
> API and migrations for basic CRUD, and is honest in code and here about
> exactly what it does and doesn't do yet. Read "Known gaps" below before
> using this for anything real. It was **not** run against a live
> FoundationDB cluster in the sandbox this was originally built in (no
> Java available); CI's `integration` job now does that on every push/PR
> -- see "Running the integration tests".

## What FRL is

FRL is Apple's SQL layer on top of FoundationDB's Record Layer (a mature
Java library for storing structured/Protobuf-backed records in FDB). You
run `fdb-relational-server` against a real FDB cluster and talk to it
either via a published JDBC driver or, as this adapter does, directly over
gRPC. It has its own DDL/SQL dialect that is close to but **not** standard
SQL:

* `STRING` (not `VARCHAR`), `BIGINT`, `BOOLEAN`, `DOUBLE`, custom `STRUCT`
  types, `VECTOR(dim, precision)` for embeddings.
* Tables and indexes are declared *inside* a `CREATE SCHEMA TEMPLATE`
  statement, not as standalone `CREATE TABLE`s:

  ```sql
  CREATE SCHEMA TEMPLATE my_template
      CREATE TABLE customers (customer_id BIGINT, name STRING, PRIMARY KEY(customer_id))
      CREATE INDEX email_idx AS SELECT email FROM customers ORDER BY email;

  CREATE DATABASE /frl/my_app;
  CREATE SCHEMA /frl/my_app/PUBLIC WITH TEMPLATE my_template;
  ```
* `INSERT`/`UPDATE`/`DELETE` with `WHERE` are standard-ish (verified
  against FoundationDB's own
  [`yaml-tests`](https://github.com/FoundationDB/fdb-record-layer/blob/main/yaml-tests/src/test/resources/inserts-updates-deletes.yamsql)).
* **FRL does not do in-memory sorting or aggregation.** `ORDER BY`,
  `GROUP BY`, and aggregates require a backing index -- see
  [`SQL_Getting_Started.md`](https://github.com/FoundationDB/fdb-record-layer/blob/main/docs/sphinx/source/SQL_Getting_Started.md).

None of the above is guesswork: it was verified this session by fetching
FRL's own docs and `yaml-tests` fixtures from
`FoundationDB/fdb-record-layer`, and (in earlier work referenced by
`ADR.md`) by actually running `fdb-relational-server` against a real FDB
cluster and connecting with the published JDBC driver.

## Architecture (see `ADR.md` for the full reasoning)

```
Ecto.Repo
  -> EctoFdbRelational.Adapter            (use Ecto.Adapters.SQL)
  -> EctoFdbRelational.Adapter.Connection (SQL text + DDL builder)
  -> DBConnection pool
  -> EctoFdbRelational.Protocol           (DBConnection driver)
  -> GRPC.Stub / Grpc.Relational.Jdbc.V1.JDBCService.Stub
  -> fdb-relational-server (JDBCService, plaintext gRPC/HTTP2)
```

This talks gRPC **directly** to `fdb-relational-server`'s
`grpc.relational.jdbc.v1.JDBCService` using real `.proto` files vendored
from `FoundationDB/fdb-record-layer`'s `fdb-relational-grpc` module (see
`priv/protos/`), compiled with `protoc`/`protoc-gen-elixir` into
`lib/ecto_fdb_relational/grpc/*.pb.ex`. There is no JDBC driver, no
embedded JVM, and no Rust NIF anywhere in this adapter -- an earlier,
unverified architectural sketch proposed exactly that, and `ADR.md`
explains in detail why it was rejected in favor of gRPC.

## Installation

```elixir
def deps do
  [
    {:ecto_fdb_relational, "~> 0.1"}
  ]
end
```

## Usage

```elixir
defmodule MyApp.Repo do
  use Ecto.Repo,
    otp_app: :my_app,
    adapter: EctoFdbRelational.Adapter
end
```

```elixir
config :my_app, MyApp.Repo,
  hostname: "localhost",
  port: 8123,                    # the -g gRPC port fdb-relational-server was started with
  database: "/frl/my_app",
  relational_schema: "PUBLIC"    # optional, defaults to "PUBLIC"
```

Standing up the server this config talks to (verified working, Maven
Central artifacts, no source build needed):

```sh
java -cp fdb-relational-server-4.3.6.0-all.jar \
  com.apple.foundationdb.relational.server.RelationalServer -g 8123 -p 8124
# reads the FDB cluster file from the FDB_CLUSTER_FILE env var (no CLI flag in this version)
```

Then, in your Elixir app: `mix ecto.create`, write migrations as usual,
`mix ecto.migrate`, and use `Repo.insert/2`, `Repo.all/2`,
`Repo.update_all/2`, `Repo.delete_all/2` etc. within the query-shape subset
described below.

## Known gaps (read this)

This is an honest list, not a roadmap teaser. Everything here raises a
clear `EctoFdbRelational.Error`/`ArgumentError` at build time rather than
silently doing the wrong thing, unless noted otherwise.

**Query builder** (`EctoFdbRelational.Adapter.Connection`):
* Single source table only -- **no joins, no subqueries**.
* No `GROUP BY`/`HAVING`/aggregates, no `DISTINCT`, no `UNION` family, no
  window functions, no CTEs. (Several of these are intrinsically
  index-backed in FRL anyway, not just unimplemented here.)
* No `LIMIT`/`OFFSET` (FRL's `Options.max_rows` in the gRPC proto looks
  like the right mechanism but isn't wired up to Ecto's `limit:` yet).
* `WHERE`/`ON` support: `==`, `!=`, `<`, `<=`, `>`, `>=`, `and`, `or`,
  `not`, `is_nil`, `in` with a *literal* list. No `like`, no fragments, no
  arithmetic, no function calls.
* `insert`/`update`/`delete` do not support `RETURNING` (`StatementResponse`
  only carries a row count, not returned rows) or `ON CONFLICT`.
* `Repo.stream/2` and `Repo.explain/2` are not implemented.

**Migrations / DDL** (`EctoFdbRelational.Ddl`, `EctoFdbRelational.SchemaTemplate`):
* FRL's DDL is holistic (a whole `CREATE SCHEMA TEMPLATE` at once), while
  Ecto's migrations are incremental. This adapter bridges the two by
  accumulating every `create table`/`create index` it has seen (in an
  in-process `Agent`) and **re-issuing the entire template, then dropping
  and recreating the target database**, on every single DDL command.
  **This is destructive: it does not preserve existing data across
  migrations.** It is fine for the common "fresh database, run all
  migrations once" workflow (dev/test, this repo's own integration test),
  but it is **not** a safe schema-evolution story for a database that
  already holds production data.
* `alter table`, `rename table/column`, and most other
  `Ecto.Migration` commands are not translated -- only `create table`
  (with `add` columns and `primary_key: true`), `drop table`,
  `create index`, `drop index`.
* No autoincrement/serial primary keys (FRL has none in the verified
  dialect) -- use `create table(:things, primary_key: false) do add
  :id, :integer, primary_key: true end` and assign IDs client-side.
* Each rematerialization mints a new schema-template name
  (`ecto_fdb_relational_..._vN`) without dropping the previous one, so old
  template versions accumulate in FRL's catalog. Minor, documented leak,
  not silently ignored.
* v0.1 only supports migrating **one FRL-backed database per BEAM node at
  a time** -- see the moduledoc on `EctoFdbRelational.Ddl` for why
  (`execute_ddl/1` has no access to repo config; the target
  database/schema is stashed in `:persistent_term` the moment a
  connection is established).
* `Ecto.Adapter.Storage.storage_status/1` is not implemented (FRL's system
  catalog schema for listing databases -- the `"TEMPLATES"` system table
  used in `create-drop.yamsql` implies a `"DATABASES"` one exists too, but
  its exact columns were not verified this session, and guessing felt
  worse than just not implementing it).

**Types** (`EctoFdbRelational.Types`): only scalar types are handled --
`:id`/`:integer`/`:bigint` -> `BIGINT`, `:string` -> `STRING`,
`:boolean` -> `BOOLEAN`, `:float`/`:decimal` -> `DOUBLE`,
`:binary` -> `BYTES`, `*_datetime` -> `BIGINT` (epoch millis). FRL's
richer type system -- `STRUCT`, arrays, `UUID`, `ENUM`, `VECTOR` -- is not
mapped yet.

**Transactions** (`EctoFdbRelational.Protocol`): `JDBCService`'s unary
`execute`/`update` RPCs are effectively autocommit-per-call. True
multi-statement transactions need the bidirectional-streaming
`handleAutoCommitOff` RPC, which is **not implemented**.
`Repo.transaction/2`/`Ecto.Multi` will run without crashing, but provide
**no atomicity or isolation guarantee** -- each statement inside is
committed independently exactly as if it were called outside the
transaction. This is stated loudly in the `EctoFdbRelational.Protocol`
moduledoc too, not just here.

**JDBC metadata introspection**: not used at all, by design (see
`ADR.md`) -- which sidesteps a real rough edge found during manual JDBC
testing this session: `DatabaseMetaData.getTables()` threw `Database
</frl/zftest6> does not exist` immediately after successfully creating and
populating that exact database. FoundationDB's own docs mark the whole
JDBC interface "experimental and not production-ready".

## Running the integration tests

`test/ecto_fdb_relational/integration_test.exs` exercises real
insert/select/update/delete through `Ecto.Repo` against a live
`fdb-relational-server` + FoundationDB cluster. It is **skipped by
default** (via `@moduletag skip: ...`, not silently passing without doing
anything) unless you point it at one:

```sh
FRL_TEST_PORT=8123 mix test test/ecto_fdb_relational/integration_test.exs
# optional: FRL_TEST_HOST=localhost FRL_TEST_DATABASE=/frl/ecto_fdb_relational_test
```

This project's own development environment (the sandbox this was
originally built in) did **not** have a live FoundationDB cluster +
`fdb-relational-server` available (no Java runtime), so the integration
suite was not run against a live server as part of *building* this
adapter. That gap is now closed in CI: the `integration` job in
[`.github/workflows/ci.yml`](.github/workflows/ci.yml) installs a real
single-node FoundationDB 7.1.26 cluster (the `foundationdb-server`
Debian package, which auto-configures itself), downloads the same
`fdb-relational-server-4.3.6.0-all.jar` referenced above from Maven
Central, starts it against that cluster, and runs
`test/ecto_fdb_relational/integration_test.exs` for real -- on every push
and pull request, not just `test/ecto_fdb_relational/adapter/connection_test.exs`
(the SQL-builder unit tests, which need no live server and always ran).

If that job goes red, or you run the integration suite locally against a
real server and hit something that contradicts a claim in this README or
`ADR.md`, that's a real bug/documentation error -- please open an issue
with what you saw.

## Development

```sh
mix deps.get
mix test
mix format --check-formatted
```

Regenerating the protobuf/gRPC stubs after touching `priv/protos/`
(requires `protoc` -- `scoop install protobuf` / `brew install protobuf` /
`apt install protobuf-compiler` -- plus `protoc-gen-elixir` from
`mix escript.install hex protobuf`, and protoc's own well-known-types
include path for `google/protobuf/any.proto`):

```sh
protoc -I priv/protos -I "$(dirname "$(dirname "$(which protoc)")")/include" \
  --elixir_out=plugins=grpc,gen_descriptors=true:./lib/ecto_fdb_relational/grpc \
  priv/protos/grpc/relational/jdbc/v1/*.proto
```

## License

Apache-2.0, matching FoundationDB Record Layer's own license (see
`LICENSE`).
