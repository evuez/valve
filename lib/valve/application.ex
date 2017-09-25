defmodule Valve.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Registry, [:unique, Valve.Registry]),
      worker(Valve.Store.adapter(), [Valve.Store.Adapter])
    ] ++ Enum.map(0..(Valve.conf(:pool_size) - 1), fn id ->
      worker(Valve.Store, [id], id: {Valve.Store, id})
    end)

    opts = [strategy: :one_for_one, name: Valve.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
