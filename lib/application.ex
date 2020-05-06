defmodule Retro.Application do
  use Application

  def start(_type, _args) do
    port = Application.get_env(:retro, :port)

    children = [
      {
        Plug.Cowboy,
        plug: Retro.Web.Router,
        scheme: :http,
        options: [
          port: port,
          compress: true,
          protocol_options: [idle_timeout: 2 * 60 * 60 * 1000]
        ]
      },
      Retro.SessionSupervisor,
      Retro.SessionCleaner
    ]

    opts = [strategy: :one_for_one, name: Retro.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
