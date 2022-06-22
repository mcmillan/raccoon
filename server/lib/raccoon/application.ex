defmodule Raccoon.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy,
       scheme: :http,
       plug: Raccoon.Router,
       options: [port: Application.get_env(:raccoon_server, :port)]},
      {Redix, {Application.get_env(:raccoon_server, :redis_url), name: :redis}}
    ]

    opts = [strategy: :one_for_one, name: Raccoon.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
