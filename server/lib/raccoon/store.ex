defmodule Raccoon.Store do
  def get do
    case Redix.command(:redis, ["GET", "raccoon_data"]) do
      {:ok, nil} ->
        []

      {:ok, data} ->
        Jason.decode!(data)
    end
  end

  def set(data) do
    Redix.command(:redis, ["SET", "raccoon_data", Jason.encode!(data)])
  end
end
