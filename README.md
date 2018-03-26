# Valve

An Elixir Plug to rate-limit requests to your web app.

## Installation

Add `valve` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:valve, "~> 0.2.0"}]
end
```

Then plug it in your pipeline:

```elixir
defmodule MyApp.Router do
  use MyApp, :router

  # ...

  pipeline :api do
    plug Valve

    # ...
  end
```

The default behavior when reaching the maximum number of requests allowed is to return an [`HTTP 429 (Too Many Requests)`](https://httpstatuses.com/429) with a `Retry-After` header.
This can be overridden by passing an `on_flood` option to the plug:

```elixir
plug Valve, on_flood: fn (conn, retry_after) -> put_status(conn, 418) |> halt() end
```

## Configuration

Put this in your config:

```elixir
config :valve,
  rate: {10, 60}, # Give 10 tokens every 60 second
  max_tokens: 20, # Give at most 20 tokens (also give 20 tokens initially)
  pool_size: 8, # Number of Valve.Store processes (how many requests can be handled simultaneously)
  store: Valve.Store.ETS # The storage adapter used to store buckets (you'll need to recompile the library if you change this)
```


## Storage adapters

For now there's only an ETS backend (`Valve.Store.ETS`), contributions are welcome!

### ETS

```elixir
config :valve, Valve.Store.ETS,
  table: :my_table, # Defaults to `:valve`
  ttl: 48 * 3_600, # How much time (in seconds) before an entry should get swept (defaults to a day)
  sweep_interval: 7_200 * 1000 # How often (in milliseconds) should stale entries be cleaned (defaults to an hour)
```
