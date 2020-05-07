use Mix.Config

config :retro,
  port: 4040 

config :retro, Retro.Token,
  issuer: "retro",
  secret_key: 64 |> :crypto.strong_rand_bytes() |> Base.encode64() |> binary_part(0,64)

config :sse,
  # Keep alive in milliseconds
  keep_alive: 1000 

import_config "config.#{Mix.env()}.exs"
