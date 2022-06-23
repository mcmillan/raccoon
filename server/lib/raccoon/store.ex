defmodule Raccoon.Store do
  def get do
    case Redix.command(:redis, ["MGET", "raccoon_data", "raccoon_updated_at"]) do
      {:ok, [nil, nil]} ->
        {:ok, [], %{}}

      {:ok, [data, updated_at]} ->
        {:ok, Jason.decode!(data), %{updated_at: updated_at}}

      _ ->
        {:error}
    end
  end

  def set(data) do
    Redix.command(
      :redis,
      [
        "MSET",
        "raccoon_data",
        Jason.encode!(data),
        "raccoon_updated_at",
        DateTime.utc_now() |> DateTime.to_iso8601()
      ]
    )
  end

  def ping do
    Redix.command(:redis, ["PING"])
  end
end
