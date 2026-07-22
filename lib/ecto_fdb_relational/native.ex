defmodule EctoFdbRelational.Native do
  @moduledoc """
  The Rustler NIF (`native/ecto_fdb_relational_nif`) that embeds a JVM and calls FRL
  directly through `bridge.Bridge` (`native/frl_bridge`) -- see ADR 0003 for why this
  replaced the gRPC transport, and the NIF crate's own moduledoc for the threading model.

  `execute/2` takes and returns raw protobuf bytes: a `Grpc.Relational.Jdbc.V1.StatementRequest`
  in, a `Grpc.Relational.Jdbc.V1.StatementResponse` out. `EctoFdbRelational.Protocol` builds and
  decodes those messages exactly as it did for the old gRPC transport -- only the transport
  underneath changed, not the wire shape.

  ## The embedded JVM's classpath

  The JVM is created exactly once, eagerly, when this module loads (via `load_data_fun`
  below feeding the classpath into the Rust NIF's own `on_load` -- see its moduledoc for
  why this isn't done lazily on the first `connect/1` call instead). The classpath itself
  -- `$ECTO_FDB_RELATIONAL_CLASSPATH` (the FRL jars, an environment concern -- see the
  README) plus this app's own `priv/java` (where `native/ecto_fdb_relational_nif/build.rs`
  compiles `bridge.Bridge.class` into, as part of `cargo build` itself -- see that
  build script's comment for why it isn't a separate Mix compiler step instead) -- is
  built by `EctoFdbRelational.Native.Classpath`, a *separate* module: Erlang won't let a
  module's `@on_load` hook call back into that same module's own functions (it isn't
  registered as loaded yet at that point), so it can't live here. Building `priv/java`
  in automatically, rather than requiring every caller to remember to append it to
  `ECTO_FDB_RELATIONAL_CLASSPATH` themselves, is what fixed a real
  `java.lang.NoClassDefFoundError: bridge/Bridge` this adapter briefly shipped with (see
  git history): this app's own bridge class should never depend on an environment
  variable being set correctly, only the external FRL jars should.
  """

  use Rustler,
    otp_app: :ecto_fdb_relational,
    crate: "ecto_fdb_relational_nif",
    load_data_fun: {EctoFdbRelational.Native.Classpath, :build}

  # These are replaced by the actual NIF at load time; they only run if the NIF
  # somehow failed to load (e.g. the compiled artifact is missing).
  #
  # A successful NIF call returns the bare value (a `reference()`/`binary()`), not an
  # `{:ok, _}` tuple -- that's how a Rust NIF returning `Result<T, rustler::Error>`
  # encodes `Ok(t)` (see rustler::error::Error's NifReturnable impl). Only the error
  # case is a tagged `{:error, reason}` tuple.
  @dialyzer {:no_return,
             connect: 1,
             execute: 2,
             close: 1,
             begin: 3,
             execute_in_transaction: 2,
             commit: 1,
             rollback: 1}

  @spec connect(String.t()) :: reference() | {:error, String.t()}
  def connect(_cluster_file), do: :erlang.nif_error(:nif_not_loaded)

  @spec execute(reference(), binary()) :: binary() | {:error, String.t()}
  def execute(_conn, _request_bytes), do: :erlang.nif_error(:nif_not_loaded)

  @spec close(reference()) :: :ok | {:error, String.t()}
  def close(_conn), do: :erlang.nif_error(:nif_not_loaded)

  # See EctoFdbRelational.Protocol's "Transactions" moduledoc section for why these
  # exist alongside execute/2 rather than replacing it: a real, explicit,
  # autocommit-disabled FDB transaction, opened against one fixed database/schema for
  # its whole lifetime (unlike execute/2, which takes database/schema per call).
  @spec begin(reference(), String.t(), String.t()) :: reference() | {:error, String.t()}
  def begin(_conn, _database, _schema), do: :erlang.nif_error(:nif_not_loaded)

  @spec execute_in_transaction(reference(), binary()) :: binary() | {:error, String.t()}
  def execute_in_transaction(_txn, _request_bytes), do: :erlang.nif_error(:nif_not_loaded)

  @spec commit(reference()) :: :ok | {:error, String.t()}
  def commit(_txn), do: :erlang.nif_error(:nif_not_loaded)

  @spec rollback(reference()) :: :ok | {:error, String.t()}
  def rollback(_txn), do: :erlang.nif_error(:nif_not_loaded)
end
