defmodule EctoFdbRelational.Bench.TpccTest do
  @moduledoc """
  Runs the ported TPC-C workload (see `bench/tpcc/`) against a real
  `fdb-relational-server` + FoundationDB cluster, for a short duration --
  proof the ported scenario executes correctly end to end, not a
  publication-grade benchmark run. Gated exactly like
  `test/ecto_fdb_relational/integration_test.exs`: skipped unless
  `FRL_TEST_PORT` points at a real server.
  """
  use ExUnit.Case, async: false

  alias EctoFdbRelational.Bench.Harness
  alias EctoFdbRelational.Bench.Tpcc.{Loader, Procedures, Repo, Schema}

  @skip_reason (if System.get_env("FRL_TEST_PORT") do
                  false
                else
                  "set FRL_TEST_PORT (and optionally FRL_TEST_HOST / FRL_TEST_DATABASE) to run " <>
                    "this against a real fdb-relational-server -- see the moduledoc"
                end)

  @moduletag :integration
  @moduletag skip: @skip_reason
  @moduletag timeout: :infinity

  setup_all do
    port = String.to_integer(System.get_env("FRL_TEST_PORT", "0"))
    host = System.get_env("FRL_TEST_HOST", "localhost")
    database = System.get_env("FRL_BENCH_DATABASE", "/FRL/TPCC_BENCH")

    Application.put_env(:ecto_fdb_relational, Repo,
      hostname: host,
      port: port,
      database: database,
      relational_schema: "PUBLIC",
      pool_size: 8
    )

    {:ok, _pid} = Repo.start_link()
    Schema.bootstrap!(database)
    Loader.load!()

    on_exit(fn -> Repo.stop() end)

    :ok
  end

  test "mixed TPC-C workload runs to completion against a real server" do
    # Standard TPC-C transaction mix (see the New-Order/Payment-heavy
    # 45/43/4/4/4 split BenchBase's own tpcc scenario uses).
    procedures = [
      %{name: "NewOrder", weight: 45, run: &Procedures.new_order/0},
      %{name: "Payment", weight: 43, run: &Procedures.payment/0},
      %{name: "OrderStatus", weight: 4, run: &Procedures.order_status/0},
      %{name: "Delivery", weight: 4, run: &Procedures.delivery/0},
      %{name: "StockLevel", weight: 4, run: &Procedures.stock_level/0}
    ]

    Harness.run(procedures, worker_count: 2, duration_ms: 5_000)
  end
end
