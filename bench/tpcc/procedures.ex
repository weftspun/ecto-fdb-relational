defmodule EctoFdbRelational.Bench.Tpcc.Procedures do
  @moduledoc """
  The five standard TPC-C transactions, translated onto this adapter's
  supported query subset.

  **Atomicity gap, stated loudly rather than hidden:**
  `EctoFdbRelational.Protocol.handle_begin/2`, `handle_commit/2`, and
  `handle_rollback/2` are documented no-ops (see that module's moduledoc)
  -- every statement below commits independently the moment it runs.
  `payment/1`'s warehouse/district/customer/history writes, and
  `new_order/1`'s stock/order_line/oorder/new_order/district writes, have
  **no cross-statement atomicity or isolation** under this adapter today.
  A crash mid-procedure can leave partial writes. This is the same,
  already-documented gap the rest of this repo lives with (see the
  README's "Known gaps" and `ADR.md`), not something new this benchmark
  port introduces -- but it's real, so it's called out at every call site
  where it actually matters, not just once in this moduledoc.

  **Aggregate gap:** `stock_level/1` needs `COUNT(DISTINCT s_i_id) ...
  WHERE s_quantity < ?`, which this adapter's query builder does not
  support (no `GROUP BY`/aggregates, see the README). Adapted here to a
  plain `Repo.all` fetch of the relevant rows followed by client-side
  `Enum` counting -- a real behavior change (the count now happens in the
  BEAM process, not the database), documented rather than silently
  swapped in as if equivalent.
  """

  import Ecto.Query

  alias EctoFdbRelational.Bench.Tpcc.Repo

  alias EctoFdbRelational.Bench.Tpcc.{
    Customer,
    District,
    Item,
    NewOrder,
    Oorder,
    OrderLine,
    Stock,
    Warehouse
  }

  alias EctoFdbRelational.Bench.Tpcc.Loader

  @doc "TPC-C NewOrder: place an order for a random basket of items."
  def new_order do
    w_id = random(1, Loader.warehouses())
    d_id = random(1, Loader.districts_per_warehouse())
    c_id = random(1, Loader.customers_per_district())
    ol_cnt = random(5, 10)
    now = System.system_time(:millisecond)

    # No cross-statement atomicity (see moduledoc): a crash here between
    # reading d_next_o_id and writing the incremented value would let a
    # concurrent NewOrder reuse the same o_id. Real, open, same as every
    # other multi-write procedure in this module.
    district = Repo.get_by!(District, d_id: d_id, d_w_id: w_id)
    o_id = district.d_next_o_id

    from(d in District, where: d.d_id == ^d_id and d.d_w_id == ^w_id)
    |> Repo.update_all(set: [d_next_o_id: o_id + 1])

    Repo.insert!(%Oorder{
      o_id: o_id,
      o_d_id: d_id,
      o_w_id: w_id,
      o_c_id: c_id,
      o_entry_d: now,
      o_carrier_id: nil,
      o_ol_cnt: ol_cnt,
      o_all_local: 1
    })

    Repo.insert!(%NewOrder{no_o_id: o_id, no_d_id: d_id, no_w_id: w_id})

    for ol_number <- 1..ol_cnt do
      i_id = random(1, Loader.items())
      item = Repo.get!(Item, i_id)
      quantity = random(1, 10)

      stock = Repo.get_by!(Stock, s_i_id: i_id, s_w_id: w_id)

      new_quantity =
        if stock.s_quantity > quantity,
          do: stock.s_quantity - quantity,
          else: stock.s_quantity + 91

      from(s in Stock, where: s.s_i_id == ^i_id and s.s_w_id == ^w_id)
      |> Repo.update_all(set: [s_quantity: new_quantity, s_ytd: stock.s_ytd + quantity])

      Repo.insert!(%OrderLine{
        ol_o_id: o_id,
        ol_d_id: d_id,
        ol_w_id: w_id,
        ol_number: ol_number,
        ol_i_id: i_id,
        ol_supply_w_id: w_id,
        ol_delivery_d: nil,
        ol_quantity: quantity,
        ol_amount: quantity * item.i_price,
        ol_dist_info: stock.s_dist_info
      })
    end

    :ok
  end

  @doc "TPC-C Payment: post a payment, updating warehouse/district/customer YTD and logging it."
  def payment do
    w_id = random(1, Loader.warehouses())
    d_id = random(1, Loader.districts_per_warehouse())
    c_id = random(1, Loader.customers_per_district())
    amount = random(1, 500) / 1 * 1.0
    now = System.system_time(:millisecond)

    # Dual-write across warehouse/district/customer + a history insert,
    # with no atomicity (see moduledoc) -- a crash partway through posts
    # a payment that's only partially reflected across these rows.
    warehouse = Repo.get!(Warehouse, w_id)

    from(w in Warehouse, where: w.w_id == ^w_id)
    |> Repo.update_all(set: [w_ytd: warehouse.w_ytd + amount])

    district = Repo.get_by!(District, d_id: d_id, d_w_id: w_id)

    from(d in District, where: d.d_id == ^d_id and d.d_w_id == ^w_id)
    |> Repo.update_all(set: [d_ytd: district.d_ytd + amount])

    customer = Repo.get_by!(Customer, c_id: c_id, c_d_id: d_id, c_w_id: w_id)

    from(c in Customer, where: c.c_id == ^c_id and c.c_d_id == ^d_id and c.c_w_id == ^w_id)
    |> Repo.update_all(
      set: [
        c_balance: customer.c_balance - amount,
        c_ytd_payment: customer.c_ytd_payment + amount
      ]
    )

    Repo.insert!(%EctoFdbRelational.Bench.Tpcc.History{
      h_c_id: c_id,
      h_c_d_id: d_id,
      h_c_w_id: w_id,
      h_d_id: d_id,
      h_w_id: w_id,
      h_date: now,
      h_amount: amount,
      h_data: "payment"
    })

    :ok
  end

  @doc "TPC-C OrderStatus: read-only lookup of a customer's most recent order and its lines."
  def order_status do
    w_id = random(1, Loader.warehouses())
    d_id = random(1, Loader.districts_per_warehouse())
    c_id = random(1, Loader.customers_per_district())

    _customer = Repo.get_by!(Customer, c_id: c_id, c_d_id: d_id, c_w_id: w_id)

    order =
      from(o in Oorder, where: o.o_c_id == ^c_id and o.o_d_id == ^d_id and o.o_w_id == ^w_id)
      |> Repo.all()
      |> List.last()

    if order do
      from(ol in OrderLine,
        where: ol.ol_o_id == ^order.o_id and ol.ol_d_id == ^d_id and ol.ol_w_id == ^w_id
      )
      |> Repo.all()
    end

    :ok
  end

  @doc "TPC-C Delivery: deliver the oldest pending new-order in one district of one warehouse."
  def delivery do
    w_id = random(1, Loader.warehouses())
    d_id = random(1, Loader.districts_per_warehouse())
    now = System.system_time(:millisecond)

    oldest =
      from(no in NewOrder, where: no.no_d_id == ^d_id and no.no_w_id == ^w_id)
      |> Repo.all()
      |> Enum.min_by(& &1.no_o_id, fn -> nil end)

    case oldest do
      nil ->
        :ok

      %{no_o_id: o_id} ->
        # No atomicity across the delete + two updates below (see moduledoc).
        from(no in NewOrder,
          where: no.no_o_id == ^o_id and no.no_d_id == ^d_id and no.no_w_id == ^w_id
        )
        |> Repo.delete_all()

        from(o in Oorder, where: o.o_id == ^o_id and o.o_d_id == ^d_id and o.o_w_id == ^w_id)
        |> Repo.update_all(set: [o_carrier_id: random(1, 10)])

        from(ol in OrderLine,
          where: ol.ol_o_id == ^o_id and ol.ol_d_id == ^d_id and ol.ol_w_id == ^w_id
        )
        |> Repo.update_all(set: [ol_delivery_d: now])

        :ok
    end
  end

  @doc """
  TPC-C StockLevel: count distinct items in a district's most recent
  orders whose stock has fallen below a threshold. See the moduledoc's
  "Aggregate gap" -- this counts client-side, not via a database
  aggregate, since this adapter doesn't support `COUNT`/`GROUP BY` yet.
  """
  def stock_level do
    w_id = random(1, Loader.warehouses())
    d_id = random(1, Loader.districts_per_warehouse())
    threshold = 50

    item_ids =
      from(ol in OrderLine, where: ol.ol_d_id == ^d_id and ol.ol_w_id == ^w_id)
      |> Repo.all()
      |> Enum.map(& &1.ol_i_id)
      |> Enum.uniq()

    low_stock_count =
      item_ids
      |> Enum.map(fn i_id -> Repo.get_by(Stock, s_i_id: i_id, s_w_id: w_id) end)
      |> Enum.reject(&is_nil/1)
      |> Enum.count(&(&1.s_quantity < threshold))

    low_stock_count
  end

  defp random(min, max), do: :rand.uniform(max - min + 1) + min - 1
end
