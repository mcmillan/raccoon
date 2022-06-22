import Config

config :logger, :console,
  metadata: [:request_id, :mfa],
  level: :debug,
  format: "[$date $time] $metadata[$level] $message\n"

config :raccoon_server, Raccoon.Scheduler,
  jobs: [
    {"0 */6 * * *", {Raccoon.Scheduler, :scrape_and_store, []}}
  ]

if Mix.env() == :dev do
  config :raccoon_server, :configure_from_env, false
  import_config("dev.exs")
else
  config :raccoon_server, :configure_from_env, true
end
