use Mix.Config

if Mix.env == :test || Mix.env == :dev,
  do: import_config "#{Mix.env}.exs"
