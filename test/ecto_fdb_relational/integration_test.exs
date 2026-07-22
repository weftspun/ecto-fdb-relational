defmodule EctoFdbRelational.IntegrationTest do
  @moduledoc """
  End-to-end tests against a **real** `fdb-relational-server` + FoundationDB
  cluster: connect, bootstrap a schema template/database/schema via DDL,
  then exercise `Repo.insert/2`, `Repo.all/2`, `Repo.update/2`,
  `Repo.delete/2`.

  These are skipped (not faked, not silently "passing" without doing
  anything) unless the environment points at a real server:

      FRL_TEST_PORT=8123 mix test test/ecto_fdb_relational/integration_test.exs

  Optional: `FRL_TEST_HOST` (default `localhost`),
  `FRL_TEST_DATABASE` (default `/frl/ecto_fdb_relational_test`).

  See the README's "Running the integration tests" section for how to
  stand up `fdb-relational-server` (Maven Central artifacts, verified
  working this session -- no source build needed) plus a real FDB cluster.
  The `integration` job in `.github/workflows/ci.yml` stands up exactly
  this (a real single-node FoundationDB cluster + a real
  `fdb-relational-server` process) and runs this suite against it on every
  push/PR -- see the README for details.
  """
  use ExUnit.Case, async: false

  alias EctoFdbRelational.Test.Repo

  @skip_reason (if System.get_env("FRL_TEST_PORT") do
                  false
                else
                  "set FRL_TEST_PORT (and optionally FRL_TEST_HOST / FRL_TEST_DATABASE) to run " <>
                    "this against a real fdb-relational-server -- see the moduledoc"
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
    port = String.to_integer(System.get_env("FRL_TEST_PORT", "0"))
    host = System.get_env("FRL_TEST_HOST", "localhost")
    database = System.get_env("FRL_TEST_DATABASE", "/frl/ecto_fdb_relational_test")

    Application.put_env(:ecto_fdb_relational, Repo,
      hostname: host,
      port: port,
      database: database,
      relational_schema: "PUBLIC",
      pool_size: 2
    )

    {:ok, _pid} = Repo.start_link()

    # Bootstrap: schema template -> database -> schema, using the exact DDL
    # dialect verified against FoundationDB/fdb-record-layer's own
    # yaml-tests (create-drop.yamsql / SQL_Getting_Started.md), issued
    # directly rather than through mix ecto.migrate so this test doesn't
    # also depend on the migration accumulator's global state.
    Repo.query!("DROP DATABASE IF EXISTS #{database}", [], command: :update)

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

    on_exit(fn -> Repo.stop() end)

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
