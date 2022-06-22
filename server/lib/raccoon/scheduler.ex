defmodule Raccoon.Scheduler do
  use Quantum, otp_app: :raccoon_server
  require Logger

  def scrape_and_store do
    Logger.info("Starting scrape_and_store job...")

    ping_healthchecks_io("start")

    with {:ok, data} <- Raccoon.Scraper.scrape(),
         {:ok, _} <- Raccoon.Store.set(data) do
      ping_healthchecks_io("success")
    else
      _ ->
        ping_healthchecks_io("failure")
    end
  end

  defp ping_healthchecks_io(status) when status in ["start", "success", "failure"] do
    healthchecks_io_url = Application.get_env(:raccoon_server, :healthchecks_io_url)

    url_suffix =
      case status do
        "start" -> "/start"
        "success" -> ""
        "failure" -> "/fail"
      end

    case healthchecks_io_url do
      nil ->
        Logger.warn("No Healthchecks.io URL to send report to")

      url ->
        HTTPoison.get("#{url}#{url_suffix}", recv_timeout: 5000)
        Logger.info("Job status (#{status}) reported as to Healthchecks.io")
    end
  end
end
