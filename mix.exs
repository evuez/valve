defmodule Valve.Mixfile do
  use Mix.Project

  def project do
    [app: :valve,
     version: "0.2.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(),
     description: "An Elixir Plug to rate-limit requests to your web app.",
     source_url: "https://github.com/evuez/valve",
     homepage_url: "https://github.com/evuez/valve"]
  end

  def application do
    [extra_applications: [:logger],
     mod: {Valve.Application, []}]
  end

  defp deps do
    [{:plug, "~> 1.5"},
     {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
     {:benchfella, "~> 0.3.0", only: [:dev, :test], runtime: false},
     {:ex_doc, ">= 0.0.0", only: :dev}]
  end

  defp package do
    [licenses: ["MIT"],
     maintainers: ["evuez <helloevuez@gmail.com>"],
     links: %{"GitHub" => "https://github.com/evuez/valve"}]
  end
end
