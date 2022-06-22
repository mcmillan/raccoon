defmodule Raccoon.Application do
  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    port = Application.get_env(:raccoon_server, :port) || raise "No port provided"
    redis_url = Application.get_env(:raccoon_server, :redis_url) || raise "No redis URL provided"

    children = [
      {Plug.Cowboy, scheme: :http, plug: Raccoon.Router, options: [port: port]},
      {Redix, {redis_url, name: :redis}},
      Raccoon.Scheduler
    ]

    Logger.info("Starting on port #{port}...")

    opts = [strategy: :one_for_one, name: Raccoon.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
