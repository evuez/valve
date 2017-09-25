use Mix.Config

config :valve,
  rate: {4, 2},
  max_tokens: 4,
  pool_size: 8,
  store: Valve.Store.ETS

config :valve, Valve.Store.ETS,
  sweep_interval: 5000,
  ttl: 2
