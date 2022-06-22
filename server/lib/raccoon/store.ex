defmodule Raccoon.Store do
  def get do
    case Redix.command(:redis, ["MGET", "raccoon_data", "raccoon_updated_at"]) do
      {:ok, [nil, nil]} ->
        []

      {:ok, [data, updated_at]} ->
        %{data: Jason.decode!(data), meta: %{updated_at: updated_at}}
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
end
