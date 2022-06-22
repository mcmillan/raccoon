import Config

config :logger, :console,
  metadata: [:request_id, :mfa],
  level: :debug,
  format: "[$date $time] $metadata[$level] $message\n"

config :raccoon_server, Raccoon.Scheduler,
  jobs: [
    {"0 */6 * * *", {Raccoon.Scheduler, :scrape_and_store, []}}
  ]

import_config("#{Mix.env()}.exs")
