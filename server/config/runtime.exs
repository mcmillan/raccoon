import Config

if Application.get_env(:raccoon_server, :configure_from_env) == true do
  config :raccoon_server, :port, String.to_integer(System.get_env("PORT"))
  config :raccoon_server, :uprn, System.get_env("UPRN")
  config :raccoon_server, :redis_url, System.get_env("REDIS_URL")
  config :raccoon_server, :healthchecks_io_url, System.get_env("HEALTHCHECKS_IO_URL")
end
