defmodule Raccoon.Scraper do
  def scrape do
    {:ok, document} = Floki.parse_document(fetch())

    data =
      document
      |> Floki.find(".collection")
      |> Enum.map(&extract_info/1)

    Raccoon.Store.set(data)
  end

  defp fetch do
    {:ok, response} =
      HTTPoison.post(
        "https://www.manchester.gov.uk/bincollections",
        URI.encode_query(%{
          mcc_bin_dates_uprn: Application.get_env(:raccoon_server, :uprn),
          mcc_bin_dates_submit: "Go"
        }),
        %{"content-type": "application/x-www-form-urlencoded"}
      )

    response.body
  end

  defp extract_info(element) do
    colour =
      element
      |> Floki.find("h3")
      |> Floki.text()
      |> String.replace("DUE TODAY", "")
      |> String.replace("Bin", "")
      |> String.trim()

    {:ok, date} =
      element
      |> Floki.find(".caption")
      |> Floki.text()
      |> String.replace("Next collection", "")
      |> String.trim()
      |> DateTimeParser.parse_date()

    %{colour: colour, date: date}
  end
end
