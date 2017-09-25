defmodule ValveTest do
  use ExUnit.Case, async: true
  use Plug.Test

  import Plug.Conn, only: [get_resp_header: 2, put_status: 2]

  doctest Valve

  setup context do
    conn = conn(:get, "/")
    %{conn: %{conn | remote_ip: {127, 0, 0, context[:line]}}}
  end

  test "does not set `retry-after` after a single request", %{conn: conn} do
    opts = Valve.init([])

    conn = Valve.call(conn, opts)

    assert [] == get_resp_header(conn, "retry-after")
  end

  test "returns a 429 and sets `retry-after` when getting too many requests", %{conn: conn} do
    opts = Valve.init([])

    for _ <- 0..3, do: Valve.call(conn, opts)
    conn = Valve.call(conn, opts)

    assert ["2"] == get_resp_header(conn, "retry-after")
    assert 429 == conn.status
  end

  test "call the user-defined callback when getting too many requests", %{conn: conn} do
    opts = Valve.init([on_flood: fn conn, _ -> put_status(conn, 418) end])

    for _ <- 0..3, do: Valve.call(conn, opts)
    conn = Valve.call(conn, opts)

    assert 418 == conn.status
  end
end
