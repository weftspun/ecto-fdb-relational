defmodule EctoFdbRelational.IntegrationTest do
  @moduledoc """
  End-to-end tests against a **real** FoundationDB cluster, with FRL embedded
  in-process (no separate `fdb-relational-server`/gRPC -- see ADR 0003):
  connect, bootstrap a schema template/database/schema via DDL, then
  exercise `Repo.insert/2`, `Repo.all/2`, `Repo.update/2`, `Repo.delete/2`.

  These are skipped (not faked, not silently "passing" without doing
  anything) unless the environment points at a real cluster:

      FRL_TEST_CLUSTER_FILE=/etc/foundationdb/fdb.cluster \
        mix test test/ecto_fdb_relational/integration_test.exs

  Optional: `FRL_TEST_DATABASE` (default `/FRL/ECTO_FDB_RELATIONAL_TEST` --
  **must be uppercase**: FRL case-folds unquoted SQL identifiers in DDL text
  to uppercase, but the `database`/`schema` fields on plain statement
  requests are used literally, uncased; a lowercase path here creates a
  database via DDL that a later statement using the same lowercase
  string then can't find, surfacing as a spurious "Database ... does not
  exist").

  See the README's "Running the integration tests" section for how to
  stand up a real FDB cluster plus this transport's `ECTO_FDB_RELATIONAL_CLASSPATH`
  prerequisite. The `integration` job in `.github/workflows/ci.yml` stands up exactly
  this (a real single-node FoundationDB cluster, no separate server process) and runs
  this suite against it on every push/PR -- see the README for details.
  """
  use ExUnit.Case, async: false

  alias EctoFdbRelational.Test.Repo

  @skip_reason (if System.get_env("FRL_TEST_CLUSTER_FILE") do
                  false
                else
                  "set FRL_TEST_CLUSTER_FILE (and optionally FRL_TEST_DATABASE) to run " <>
                    "this against a real FoundationDB cluster -- see the moduledoc"
                end)

  @moduletag :integration
  @moduletag skip: @skip_reason

  defmodule Customer do
    @moduledoc false
    use Ecto.Schema

    @primary_key {:id, :integer, autogenerate: false}
    schema "customers" do
      field(:name, :string)
      field(:email, :string)
    end
  end

  setup_all do
    cluster_file = System.get_env("FRL_TEST_CLUSTER_FILE")
    database = System.get_env("FRL_TEST_DATABASE", "/FRL/ECTO_FDB_RELATIONAL_TEST")

    Application.put_env(:ecto_fdb_relational, Repo,
      cluster_file: cluster_file,
      database: database,
      relational_schema: "PUBLIC",
      pool_size: 2
    )

    # Started via `start_supervised!/1` (ExUnit's own dedicated test
    # supervisor), not `Repo.start_link/0` + a plain `on_exit(fn ->
    # Repo.stop() end)`: `setup_all` runs in a short-lived process that
    # ExUnit deliberately terminates (with a plain, ordinary `:normal` exit)
    # right after all tests in this module finish but *before* running any
    # `on_exit` callbacks (see `ExUnit.Runner.run_setup_all/4`, the "we keep
    # the process alive so all of its resources stay alive" comment).
    # `Repo.start_link/0` links the calling process to the new Repo
    # supervisor, same as any other `start_link` -- so that ordinary exit
    # collaterally tears down the (still trapping-exits) linked Repo
    # supervisor too, racing directly against the `on_exit` callback that
    # then tries to `Repo.stop()` it: exactly the "failure on setup_all
    # callback" `GenServer.stop(..., :normal, 5000)` teardown crash CI hit,
    # even though the actual test body above always passed. Routing through
    # ExUnit's own long-lived test supervisor sidesteps this: the Repo gets
    # supervised by *that* stable process instead, and ExUnit synchronously
    # (and correctly) tears it down when the case finishes -- no manual
    # `Repo.stop()`/`on_exit` needed at all.
    _pid = start_supervised!(Repo)

    # Bootstrap: schema template -> database -> schema, using the exact DDL
    # dialect verified against FoundationDB/fdb-record-layer's own
    # yaml-tests (create-drop.yamsql / SQL_Getting_Started.md), issued
    # directly rather than through mix ecto.migrate so this test doesn't
    # also depend on the migration accumulator's global state.
    #
    # Both the database *and* the schema template are dropped first: a
    # schema using a template can't be re-created against a template that
    # already exists (dropping only the database left "Schema template
    # already exists: ECTO_FDB_RELATIONAL_IT" behind for the *next* run
    # against this same cluster/catalog, which does not get wiped between
    # local test runs the way CI's fresh cluster does).
    Repo.query!("DROP DATABASE IF EXISTS #{database}", [], command: :update)
    Repo.query!("DROP SCHEMA TEMPLATE IF EXISTS ecto_fdb_relational_it", [], command: :update)

    Repo.query!(
      "CREATE SCHEMA TEMPLATE ecto_fdb_relational_it " <>
        "CREATE TABLE customers (id BIGINT, name STRING, email STRING, PRIMARY KEY(id))",
      [],
      command: :update
    )

    Repo.query!("CREATE DATABASE #{database}", [], command: :update)

    Repo.query!(
      "CREATE SCHEMA #{database}/PUBLIC WITH TEMPLATE ecto_fdb_relational_it",
      [],
      command: :update
    )

    :ok
  end

  test "insert, select, update, delete round-trip through Ecto's query API" do
    {:ok, customer} =
      %Customer{id: 1, name: "Alice", email: "alice@example.com"}
      |> Ecto.Changeset.change()
      |> Repo.insert()

    assert customer.id == 1

    [fetched] = Repo.all(Customer)
    assert fetched.name == "Alice"
    assert fetched.email == "alice@example.com"

    import Ecto.Query
    found = Repo.one(from(c in Customer, where: c.email == ^"alice@example.com"))
    assert found.id == 1

    {1, nil} =
      from(c in Customer, where: c.id == ^1)
      |> Repo.update_all(set: [name: "Alice Updated"])

    assert Repo.get(Customer, 1).name == "Alice Updated"

    {1, nil} = from(c in Customer, where: c.id == ^1) |> Repo.delete_all()
    assert Repo.all(Customer) == []
  end
end
