defmodule Retro.MixProject do
  use Mix.Project

  def project do
    [
      app: :retro,
      version: File.read!("VERSION") |> String.trim(),
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [
        :logger,
        :plug,
        :event_bus
      ],
      mod: {Retro.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.10"},
      {:plug_cowboy, "~> 2.1"},
      {:poison, "~> 4.0"},
      {:earmark, "~> 1.4"},
      {:uuid, "~> 1.1"},
      {:guardian, "~> 2.0"},
      {:cors_plug, "~> 2.0"},
      {:sse, "~> 0.4"},
      {:event_bus, "~> 1.6"}
    ]
  end
end
