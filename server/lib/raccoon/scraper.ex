defmodule Raccoon.Scraper do
  require Logger

  def scrape do
    with {:ok, html} <- fetch_html(),
         {:ok, document} <- parse_html(html),
         {:ok, collection_elements} <- extract_collection_elements(document),
         {:ok, result} <- extract_collection_info(collection_elements) do
      {:ok, result}
    else
      _ ->
        {:error}
    end
  end

  defp fetch_html do
    Logger.info("Requesting data from manchester.gov.uk...")

    uprn = Application.get_env(:raccoon_server, :uprn) || raise "No UPRN to retrieve from"

    request =
      HTTPoison.post(
        "https://www.manchester.gov.uk/bincollections",
        URI.encode_query(%{
          mcc_bin_dates_uprn: uprn,
          mcc_bin_dates_submit: "Go"
        }),
        %{
          "content-type": "application/x-www-form-urlencoded",
          "user-agent": "raccoon (github.com/mcmillan/raccoon)"
        },
        timeout: 30_000,
        recv_timeout: 30_000
      )

    case request do
      {:ok, %{status_code: 200, body: body}} ->
        Logger.info("Successfully retrieved page")
        {:ok, body}

      {:ok, response} ->
        Logger.error(
          "Non-200 response code returned from manchester.gov.uk: #{response.status_code}"
        )

        {:error}

      {:error, error} ->
        Logger.error("Unable to retrieve data: #{error.reason}")
        {:error}
    end
  end

  defp parse_html(html) do
    Logger.info("Parsing HTML...")

    case html |> Floki.parse_document() do
      {:ok, document} ->
        Logger.info("Parsed successfully")
        {:ok, document}

      {:error, error} ->
        Logger.error("Unable to parse HTML: #{error}")
        {:error}
    end
  end

  defp extract_collection_elements(document) do
    Logger.info("Extracting collections...")

    collections = document |> Floki.find(".collection")

    case Enum.count(collections) do
      count when count > 0 ->
        Logger.info("#{count} collections found")
        {:ok, collections}

      _ ->
        Logger.error("No collections found (malformed HTML?)")
        {:error}
    end
  end

  defp extract_collection_info(elements) when is_list(elements) == true do
    Enum.reduce(
      elements,
      {:ok, []},
      fn element, prev ->
        result = extract_collection_info(element)

        case {prev, result} do
          {{:error}, _} ->
            {:error}

          {{:ok, _}, {:error, _}} ->
            {:error}

          {{:ok, prev_data}, {:ok, data}} ->
            {:ok, [data | prev_data]}
        end
      end
    )
  end

  defp extract_collection_info(element) when is_list(element) == false do
    Logger.info("Extracting collection info from element...")

    colour =
      element
      |> Floki.find("h3")
      |> Floki.text()
      |> String.replace("DUE TODAY", "")
      |> String.replace("Bin", "")
      |> String.trim()

    date =
      element
      |> Floki.find(".caption")
      |> Floki.text()
      |> String.replace("Next collection", "")
      |> String.trim()
      |> DateTimeParser.parse_date()

    case {colour, date} do
      {"", _} ->
        Logger.error("Unable to extract a valid colour")
        {:error}

      {_, {:error, error}} ->
        Logger.error("Unable to extract a valid date: #{error}")
        {:error}

      {colour, {:ok, date}} ->
        Logger.info("Extracted #{colour} on #{date}")
        {:ok, %{id: colour_to_id(colour), colour: colour, date: date}}
    end
  end

  defp colour_to_id(colour) do
    colour
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s]+/, "")
    |> String.trim()
    |> String.replace(~r/\s+/, "_")
  end
end
