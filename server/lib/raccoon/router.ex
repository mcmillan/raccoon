defmodule Raccoon.Router do
  use Plug.Router

  plug(Plug.RequestId)
  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/collections" do
    json_string = Jason.encode!(Raccoon.Store.get())

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, json_string)
  end

  get "/healthz" do
    case Raccoon.Store.ping() do
      {:ok, _} ->
        send_resp(conn, 204, "")

      _ ->
        send_resp(conn, 500, "")
    end
  end

  match _ do
    send_resp(conn, 404, "")
  end
end
