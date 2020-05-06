use Mix.Config

config :retro,
  port: 4040 


config :cors_plug,
  origin: ["*"],
  max_age: 86400,
  methods: ["GET", "PUT", "POST", "DELETE"]
