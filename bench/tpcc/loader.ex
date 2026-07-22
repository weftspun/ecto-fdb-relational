defmodule EctoFdbRelational.Bench.Tpcc.Loader do
  @moduledoc """
  Seeds a small, fixed TPC-C dataset -- enough for the workload in
  `EctoFdbRelational.Bench.Tpcc.Procedures` to have real rows to contend
  over. This is **not yet** a scale-factor-accurate TPC-C dataset
  generator matching BenchBase's own loader (proportional
  warehouses/districts/customers/items driven by a configurable scale
  factor, skewed random selection, etc.) -- reproducing that faithfully
  *is* the eventual point of this port, just not done in this first cut.
  Proving the workload executes correctly against this adapter came
  first; matching BenchBase's real load-generation fidelity is follow-up
  work, not something dismissed as out of scope.
  """

  alias EctoFdbRelational.Bench.Tpcc.Repo
  alias EctoFdbRelational.Bench.Tpcc.{Customer, District, Item, Stock, Warehouse}

  @warehouses 2
  @districts_per_warehouse 2
  @customers_per_district 10
  @items 20

  def warehouses, do: @warehouses
  def districts_per_warehouse, do: @districts_per_warehouse
  def customers_per_district, do: @customers_per_district
  def items, do: @items

  def load! do
    Enum.each(1..@items, fn i_id ->
      Repo.insert!(%Item{
        i_id: i_id,
        i_im_id: i_id,
        i_name: "item#{i_id}",
        i_price: 9.99,
        i_data: "data"
      })
    end)

    for w_id <- 1..@warehouses do
      Repo.insert!(%Warehouse{w_id: w_id, w_name: "W#{w_id}", w_tax: 0.05, w_ytd: 0.0})

      for i_id <- 1..@items do
        Repo.insert!(%Stock{
          s_i_id: i_id,
          s_w_id: w_id,
          s_quantity: 100,
          s_dist_info: "dist",
          s_ytd: 0.0,
          s_order_cnt: 0,
          s_remote_cnt: 0,
          s_data: "data"
        })
      end

      for d_id <- 1..@districts_per_warehouse do
        Repo.insert!(%District{
          d_id: d_id,
          d_w_id: w_id,
          d_name: "D#{d_id}",
          d_tax: 0.04,
          d_ytd: 0.0,
          d_next_o_id: 1
        })

        for c_id <- 1..@customers_per_district do
          Repo.insert!(%Customer{
            c_id: c_id,
            c_d_id: d_id,
            c_w_id: w_id,
            c_first: "First#{c_id}",
            c_last: "Last#{c_id}",
            c_credit: "GC",
            c_credit_lim: 50_000.0,
            c_discount: 0.1,
            c_balance: -10.0,
            c_ytd_payment: 10.0
          })
        end
      end
    end

    :ok
  end
end
