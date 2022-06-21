import Config

config :logger, :console,
  metadata: [:request_id],
  format: "[$date $time] $metadata$level: $message\n"

import_config("#{Mix.env()}.exs")
