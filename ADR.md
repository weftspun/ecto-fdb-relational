# ADR 0001: talk gRPC directly to `fdb-relational-server`, not JDBC/a JVM/a Rust NIF

## Status

Accepted, v0.1.

## Context

An earlier, *unverified* sketch for this adapter proposed: `Ecto` ->
`Ecto.Adapters.SQL` -> a `DBConnection` implementation -> a Rustler NIF ->
an embedded JVM running FRL's published JDBC driver
(`org.foundationdb:fdb-relational-jdbc`), with DDL translated ad hoc
per-statement. That sketch was never verified against a real server and had
real, foreseeable problems:

* An embedded JVM inside a BEAM NIF is unusual and risky: JVM startup cost,
  GC pauses, and long-running/blocking JDBC calls do not play well with
  NIFs (even "dirty" NIFs are meant to be bounded; a JDBC call can block for
  an arbitrary amount of time) and can starve the BEAM scheduler.
* It requires shipping and managing a JVM + the JDBC driver jar as a runtime
  dependency of an Elixir library, which is a heavy, unusual ask for
  `hex.pm` consumers compared to every other real community Ecto adapter
  (`postgrex`, `myxql`, `ecto_sqlite3`), none of which embed another
  language runtime.
* FoundationDB's own docs mark the whole JDBC interface "experimental and
  not production-ready" -- riding on top of it doesn't buy much stability.

## What was actually verified this session (not guessed)

1. `fdb-relational-server` (Maven Central,
   `org.foundationdb:fdb-relational-server:4.3.6.0:all`, main class
   `com.apple.foundationdb.relational.server.RelationalServer`, started with
   `-g <grpcPort> -p <httpPort>` and the `FDB_CLUSTER_FILE` env var) was
   stood up against a real FoundationDB cluster and connected to
   successfully via the published JDBC driver, in an earlier part of this
   work.
2. On startup it advertises three gRPC services:
   `grpc.relational.jdbc.v1.JDBCService`, `grpc.health.v1.Health`, and
   `grpc.reflection.v1alpha.ServerReflection`.
3. The `.proto` files for `JDBCService` are public, versioned source in the
   `fdb-relational-grpc` module of `FoundationDB/fdb-record-layer`:
   `fdb-relational-grpc/src/main/proto/grpc/relational/jdbc/v1/{jdbc,column,result_set,continuation}.proto`.
   They are vendored verbatim (with their original Apache-2.0 license
   header intact) in this repo at
   `priv/protos/grpc/relational/jdbc/v1/`.
4. `JDBCService` exposes exactly what an Ecto SQL adapter needs, with SQL
   text as the actual "query language" (not a bespoke structured query
   API):

   ```protobuf
   service JDBCService {
     rpc getMetaData(DatabaseMetaDataRequest) returns (DatabaseMetaDataResponse) {}
     rpc execute(StatementRequest) returns (StatementResponse) {}          // SELECT
     rpc update(StatementRequest) returns (StatementResponse) {}          // INSERT/UPDATE/DELETE/DDL
     rpc insert(InsertRequest) returns (InsertResponse) {}                // Direct Access API, not used by this adapter
     rpc get(GetRequest) returns (GetResponse) {}                        // Direct Access API, not used by this adapter
     rpc scan(ScanRequest) returns (ScanResponse) {}                     // Direct Access API, not used by this adapter
     rpc handleAutoCommitOff(stream TransactionalRequest) returns (stream TransactionalResponse) {}
   }
   ```

   `StatementRequest` carries `sql` (full text), `database`, `schema`, and
   positional `parameters` -- exactly the shape `Ecto.Adapters.SQL.Connection`
   already expects a driver to produce.
5. `protoc` (installed via `scoop install protobuf`, v35.1) plus
   `protoc-gen-elixir` (from the `protobuf` hex package, v0.17.0) generate
   real, compiling Elixir modules from those vendored `.proto` files with
   no manual editing -- see `lib/ecto_fdb_relational/grpc/*.pb.ex`, which
   includes a real `Grpc.Relational.Jdbc.V1.JDBCService.Stub` gRPC client.

## Decision

Talk gRPC **directly** from Elixir to `fdb-relational-server`, using the
`grpc`/`protobuf` hex packages and the vendored, real `.proto` files. No
JDBC, no embedded JVM, no Rust NIF, no FFI of any kind.

```
Ecto.Repo
  -> EctoFdbRelational.Adapter            (use Ecto.Adapters.SQL)
  -> EctoFdbRelational.Adapter.Connection (Ecto.Adapters.SQL.Connection: SQL text + DDL builder)
  -> DBConnection pool
  -> EctoFdbRelational.Protocol           (DBConnection driver)
  -> GRPC.Stub / Grpc.Relational.Jdbc.V1.JDBCService.Stub
  -> fdb-relational-server (JDBCService, plaintext gRPC/HTTP2)
```

This is architecturally the same shape as every other real Ecto SQL
adapter (a `DBConnection` driver talking a wire protocol directly, wrapped
by `Ecto.Adapters.SQL`), just with gRPC/protobuf instead of a
Postgres/MySQL/SQLite wire format. It has none of the embedded-runtime
risk of the NIF+JVM sketch, and depends only on pure-Elixir/Erlang
libraries (`grpc`, `protobuf`, `db_connection`) already on hex.pm.

## Consequences

* No JDBC `DatabaseMetaData` introspection is available or needed --
  which sidesteps the `getTables()`/`getColumns()` bug/rough-edge noted
  during manual JDBC testing this session (`Database </frl/zftest6> does
  not exist` thrown immediately after successfully creating and populating
  that exact database). This adapter tracks schema state itself instead
  (see `EctoFdbRelational.SchemaTemplate` and `EctoFdbRelational.Ddl`) --
  which was going to be necessary regardless of transport, since FRL's
  schema-template DDL model doesn't match Ecto's incremental migration
  model either way (see the README's "Known gaps").
* `JDBCService`'s unary `execute`/`update` RPCs are effectively
  autocommit-per-call; real cross-statement transactions require the
  bidirectional-streaming `handleAutoCommitOff` RPC, which is **not**
  implemented in v0.1 (see `EctoFdbRelational.Protocol` moduledoc and the
  README). This is a real, load-bearing limitation of this decision, not
  hidden: it was true regardless of transport (JDBC's own
  `Connection.setAutoCommit(false)` presumably drives the same streaming
  RPC under the hood), but is called out here because it directly affects
  what `Repo.transaction/2`/`Ecto.Multi` can safely be used for today.
* The Direct Access API (`get`/`scan`/`insert` RPCs, which move data via a
  `KeySet` rather than SQL text) is not used by this adapter. It's a real,
  potentially more efficient path for point lookups, but adopting it would
  mean bypassing Ecto's SQL query builder entirely for those cases -- left
  as future work, not started here.
