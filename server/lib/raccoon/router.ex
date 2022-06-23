defmodule Raccoon.Router do
  use Plug.Router

  plug(Plug.RequestId, http_header: "raccoon-request-id")
  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/collections" do
    {:ok, data, meta} = Raccoon.Store.get()

    send_json(conn, data, meta)
  end

  get "/healthz" do
    case Raccoon.Store.ping() do
      {:ok, _} ->
        send_json(conn, %{redis: :ok})

      _ ->
        send_empty_body(conn, 500)
    end
  end

  match _ do
    send_empty_body(conn, 404)
  end

  defp send_json(conn, data) when is_list(data) or is_map(data) do
    send_json(conn, data, nil, 200)
  end

  defp send_json(conn, data, meta)
       when (is_list(data) or is_map(data)) and (is_map(meta) or is_nil(meta)) do
    send_json(conn, data, meta, 200)
  end

  defp send_json(conn, data, meta, status)
       when (is_list(data) or is_map(data)) and (is_map(meta) or is_nil(meta)) and
              status in 200..599 do
    json_string = Jason.encode!(%{data: data, meta: meta || %{}})

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(status, json_string)
  end

  defp send_empty_body(conn, status) when status in 200..599 do
    send_resp(conn, status, "")
  end
end
