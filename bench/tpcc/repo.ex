defmodule EctoFdbRelational.Bench.Tpcc.Repo do
  @moduledoc """
  Only used by the tpcc benchmark, gated exactly like
  `test/support/repo.ex` -- see `test/bench_tpcc_test.exs`.
  """
  use Ecto.Repo,
    otp_app: :ecto_fdb_relational,
    adapter: EctoFdbRelational.Adapter
end
