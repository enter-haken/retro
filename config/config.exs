use Mix.Config

config :retro,
  port: 4040 

config :retro, Retro.Token,
  issuer: "retro",
  secret_key: "YN04NIKumaN/HSkTZWzPHVFLBCveZgusFGOm31+aGLe073IJSELxAK2DMVEo3UwT"

config :sse,
  # Keep alive in milliseconds
  #keep_alive: {:system, "SSE_KEEP_ALIVE_IN_MS", 2 * 60 * 60 * 1000 }
  keep_alive: 1000 

import_config "config.#{Mix.env()}.exs"
