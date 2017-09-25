defmodule Valve do
  @moduledoc """
  An Elixir Plug to rate limit requests.
  """

  defmodule Bucket do
    @moduledoc false

    @type t :: %__MODULE__{last_request: integer, tokens: float}
    defstruct [:last_request, :tokens]
  end

  import Plug.Conn, only: [halt: 1, put_resp_header: 3, send_resp: 3]

  alias Valve.Store

  @doc false
  def init([on_flood: on_flood] = opts) when is_function(on_flood, 2),
    do: opts
  def init(_opts), do: [on_flood: &Valve.flood_resp/2]

  @doc false
  def call(%Plug.Conn{remote_ip: remote_ip} = conn, on_flood: on_flood) do
    %Bucket{last_request: last_request, tokens: tokens} = Store.grab(remote_ip)

    {last_request, tokens} = refresh(last_request, tokens)

    if tokens > 0 do
      Store.put(remote_ip, %Bucket{last_request: last_request, tokens: tokens - 1})
      conn
    else
      on_flood.(conn, conf(:rate) |> elem(1))
    end
  end

  @doc false
  def now, do: DateTime.utc_now() |> DateTime.to_unix()

  @doc false
  def conf(key), do: Application.fetch_env!(:valve, key)

  @doc """
  Default response when there is no token left in a bucket.
  """
  def flood_resp(conn, retry_after) do
    conn
    |> put_resp_header("retry-after", retry_after |> Integer.to_string)
    |> send_resp(:too_many_requests, "")
    |> halt()
  end

  # Update `last_request` and `tokens` if needed.
  defp refresh(last_request, tokens) do
    {reward, interval} = conf(:rate)
    pause = now() - last_request

    if pause >= interval,
      do: {now() - rem(pause, interval),
           min(tokens + div(pause, interval) * reward, conf(:max_tokens))},
      else: {last_request, tokens}
  end
end
