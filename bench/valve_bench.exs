defmodule ValveBench do
  use Benchfella
  use Plug.Test

  @range 1..10_000

  before_each_bench _ do
    Application.ensure_all_started(:valve)
  end

  after_each_bench _ do
    Application.stop(:valve)
  end

  bench "1 ip, 10 000 requests", [params: params()] do
    for _ <- @range, do: Valve.call(params[:conn], params[:opts])
    :ok
  end

  bench "10 000 ips, 10 000 requests", [params: params()] do
    for i <- @range,
      do: Valve.call(%{params[:conn] | remote_ip: {127, 0, 0, i}}, params[:opts])

    :ok
  end

  bench "1 ip, 10 000 requests, async", [params: params()] do
    Task.async_stream(@range, fn _ -> Valve.call(params[:conn], params[:opts]) end)
    |> Enum.to_list

    :ok
  end

  bench "10 000 ips, 10 000 requests, async", [params: params()] do
    Task.async_stream(@range, fn i ->
      Valve.call(%{params[:conn] | remote_ip: {127, 0, 0, i}}, params[:opts])
    end)
    |> Enum.to_list

    :ok
  end

  def params do
    conn = conn(:get, "/")
    opts = Valve.init([])
    %{conn: conn, opts: opts}
  end
end
