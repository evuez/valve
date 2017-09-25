defmodule Valve.Store.ETS do
  @moduledoc """
  An ETS-backed store for Valve.
  """
  use GenServer
  require Logger

  @behaviour Valve.Store

  @table :valve
  @ttl 24 * 3600 * 1000
  @sweep_interval 3600 * 1000

  def start_link(name), do: GenServer.start_link(__MODULE__, nil, name: name)

  def init(nil) do
    :ets.new(table(), [:set, :public, :named_table])
    schedule_sweep()
    {:ok, nil}
  end

  # Store callbacks

  def get(ip), do: lookup(ip)

  def put(ip, bucket), do: insert(ip, bucket)

  # GenServer callbacks

  def handle_info(:sweep, nil) do
    sweep()
    schedule_sweep()
    {:noreply, nil}
  end

  # Helpers

  defp lookup(key) do
    case :ets.lookup(table(), key) do
      [{^key, value}] -> value
      [] -> nil
    end
  end

  defp insert(key, value) do
    :ets.insert(table(), {key, value})
    value
  end

  defp schedule_sweep do
    interval = Valve.conf(__MODULE__)[:sweep_interval] || @sweep_interval
    Process.send_after(self(), :sweep, interval)
  end

  defp sweep do
    now = Valve.now()
    ttl = Valve.conf(__MODULE__)[:ttl] || @ttl

    spec = [{{:_, %{last_request: :"$1"}}, [{:>, {:-, now, :"$1"}, ttl}], [true]}]
    count = :ets.select_delete(table(), spec)

    Logger.debug fn -> "Sweeped #{count} entries" end
  end

  defp table, do: Valve.conf(__MODULE__)[:table] || @table
end
