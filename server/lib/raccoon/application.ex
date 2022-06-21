defmodule Raccoon.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Raccoon.Router, options: [port: 8080]}
    ]

    opts = [strategy: :one_for_one, name: Raccoon.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
