import Config

config :raccoon_server, :port, System.get_env("PORT")
config :raccoon_server, :uprn, System.get_env("RACCOON_UPRN")
