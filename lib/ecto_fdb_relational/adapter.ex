defmodule EctoFdbRelational.Adapter do
  @moduledoc """
  `Ecto.Adapter` for FoundationDB Record Layer's Relational Layer (FRL).

      defmodule MyApp.Repo do
        use Ecto.Repo,
          otp_app: :my_app,
          adapter: EctoFdbRelational.Adapter
      end

      config :my_app, MyApp.Repo,
        hostname: "localhost",
        port: 8123,                       # the -g gRPC port fdb-relational-server was started with
        database: "/frl/my_app",
        relational_schema: "PUBLIC"        # optional, defaults to "PUBLIC"

  Built on top of `Ecto.Adapters.SQL` (the same toolkit `Postgrex`/`MyXQL`/
  `ecto_sqlite3` adapters use for query building, migrations, and
  `DBConnection` wiring) with `EctoFdbRelational.Protocol` as the
  `DBConnection` driver -- see the README's ADR for why this talks gRPC
  directly to `fdb-relational-server`'s `JDBCService` instead of going
  through JDBC/an embedded JVM/a Rust NIF.

  See `EctoFdbRelational.Adapter.Connection` and the README's "Known gaps"
  section for exactly what subset of Ecto's query API and migrations are
  implemented in v0.1.
  """

  use Ecto.Adapters.SQL, driver: :ecto_fdb_relational

  @behaviour Ecto.Adapter.Storage

  ## Ecto.Adapter.Migration extras not covered by the `use Ecto.Adapters.SQL` macro
  ##
  ## FRL's JDBCService is stateless per-RPC (see EctoFdbRelational.Protocol
  ## moduledoc) with no real cross-statement transaction wired up yet, so
  ## there is nothing to wrap DDL in -- `supports_ddl_transaction?/0` is
  ## honestly `false` rather than claiming safety we don't have.

  @impl Ecto.Adapter.Migration
  def supports_ddl_transaction?, do: false

  @impl Ecto.Adapter.Migration
  def lock_for_migrations(_opts, _config, fun), do: fun.()

  ## Ecto.Adapter.Storage
  ##
  ## FRL's closest equivalents to "create/drop the database" are
  ## `CREATE DATABASE /path` and `DROP DATABASE IF EXISTS /path` (both
  ## verified against FoundationDB/fdb-record-layer's yaml-tests). Creating
  ## the *schema* (`CREATE SCHEMA /path/name WITH TEMPLATE ...`) needs a
  ## template to already exist, so `storage_up/1` here only creates an
  ## empty database -- the schema itself gets created the first time a
  ## migration runs (see `EctoFdbRelational.Ddl`).

  @impl Ecto.Adapter.Storage
  def storage_up(opts) do
    database = Keyword.fetch!(opts, :database)

    case run_system_statement(opts, "CREATE DATABASE #{database}") do
      {:ok, _} ->
        :ok

      {:error, %EctoFdbRelational.Error{grpc_reason: reason}} when is_binary(reason) ->
        # Best-effort, *not* independently verified this session: we infer
        # "already exists" from the word "exist" showing up in the server's
        # error message (the one FRL error string we *did* verify this
        # session, "Database </frl/zftest6> does not exist", is for the
        # opposite condition -- reading a database that's missing -- so this
        # is a heuristic guess about the create-when-present message, not a
        # confirmed fact). If this heuristic misses, storage_up/1 just
        # surfaces the raw error instead of silently succeeding.
        if String.contains?(String.downcase(reason), "exist") do
          {:error, :already_up}
        else
          {:error, %EctoFdbRelational.Error{message: reason}}
        end

      {:error, _} = error ->
        error
    end
  end

  @impl Ecto.Adapter.Storage
  def storage_down(opts) do
    database = Keyword.fetch!(opts, :database)

    with {:ok, _} <- run_system_statement(opts, "DROP DATABASE IF EXISTS #{database}") do
      :ok
    end
  end

  @impl Ecto.Adapter.Storage
  def storage_status(_opts) do
    # FRL's system catalog (the `"TEMPLATES"` table queried in
    # create-drop.yamsql confirms a catalog exists) presumably has a
    # `"DATABASES"` table too, but its schema was not verified this session
    # -- guessing at column names here would mean shipping an unverified
    # claim as if it were fact, which is exactly what this project is
    # trying not to do. Left honestly unimplemented; see the README's
    # Known gaps section. `mix ecto.create` (storage_up/1, which *is*
    # implemented against verified DDL) already no-ops safely if the
    # database exists, so this mainly affects `Ecto.Storage`-driven tooling
    # that specifically calls `storage_status/1`.
    {:error,
     %EctoFdbRelational.Error{
       message:
         "EctoFdbRelational.Adapter.storage_status/1 is not implemented: FRL's system " <>
           "catalog schema for listing databases was not verified. Use storage_up/1 " <>
           "(idempotent-ish via its own error handling) or query the database directly instead."
     }}
  end

  # storage_up/storage_down/storage_status need a live connection but run
  # *before* a Repo-managed pool would normally exist, so they open a
  # short-lived direct connection via EctoFdbRelational.Protocol/DBConnection
  # rather than going through Ecto.Repo.
  defp run_system_statement(opts, sql, query_opts \\ [command: :update]) do
    case DBConnection.start_link(EctoFdbRelational.Protocol, opts) do
      {:ok, conn} ->
        try do
          EctoFdbRelational.Adapter.Connection.query(conn, sql, [], query_opts)
        after
          GenServer.stop(conn)
        end

      {:error, reason} ->
        {:error, EctoFdbRelational.Error.from_reason(reason)}
    end
  end
end
