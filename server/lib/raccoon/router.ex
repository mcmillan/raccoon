defmodule Raccoon.Router do
  use Plug.Router

  plug(Plug.RequestId)
  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/" do
    json_string = Jason.encode!(%{bins: []})

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, json_string)
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
