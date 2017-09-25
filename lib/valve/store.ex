defmodule Valve.Store do
  @moduledoc """
  A behaviour that can be used to implement a backend storage for Valve.

  Any implementation should implement its own sweeping / cleanup system.
  """
  use GenServer

  alias Valve.Bucket

  @adapter Application.fetch_env!(:valve, :store)

  # Callbacks

  @callback start_link(name :: atom) :: {:ok, pid}

  @callback get(ip :: String.t) :: Bucket.t | nil
  @callback put(ip :: String.t, bucket :: Bucket.t) :: Bucket.t

  # API

  defdelegate get(ip), to: @adapter

  defdelegate put(ip, bucket), to: @adapter

  def grab(ip),
    do: GenServer.call(name(ip), {:grab, ip})

  @doc false
  def adapter, do: @adapter

  # GenServer

  def start_link(id),
    do: GenServer.start_link(__MODULE__, nil, name: name(id))

  def handle_call({:grab, ip}, _from, _state) do
    bucket = case get(ip) do
      %Bucket{} = bucket -> bucket
      nil ->
        bucket = %Bucket{last_request: Valve.now(), tokens: Valve.conf(:max_tokens)}
        put(ip, bucket)
        bucket
    end

    {:reply, bucket, nil}
  end

  # Helpers

  defp name(ip) when is_tuple(ip), do: {:via, Registry, {Valve.Registry, hash(ip)}}
  defp name(id), do: {:via, Registry, {Valve.Registry, id}}

  defp hash({a, b, c, d}), do: rem(a + b + c + d, Valve.conf(:pool_size))
  defp hash({a, b, c, d, e, f, g, h}),
    do: rem(a + b + c + d + e + f + g + h, Valve.conf(:pool_size))
end
