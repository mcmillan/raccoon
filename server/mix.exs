defmodule Raccoon.MixProject do
  use Mix.Project

  def project do
    [
      app: :raccoon_server,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Raccoon.Application, []}
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.3"},
      {:floki, "~> 0.32.0"},
      {:date_time_parser, "~> 1.1.2"},
      {:httpoison, "~> 1.8"},
      {:redix, "~> 1.1"},
      {:quantum, "~> 3.0"}
    ]
  end
end
