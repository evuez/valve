use Mix.Config

config :valve,
  rate: {10, 60}, # Give 10 tokens every 60 second
  max_tokens: 20, # Give at most 20 tokens (also give 20 tokens initially)
  pool_size: 8, # Number of Valve.Store processes
  store: Valve.Store.ETS

config :valve, Valve.Store.ETS,
  table: :valve,
  sweep_interval: 3600 * 1000, # Sweep every hour
  ttl: 24 * 3600 # Sweep any entry older than a day
