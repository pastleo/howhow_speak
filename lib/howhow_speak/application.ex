defmodule HowhowSpeak.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      HowhowSpeak.SoundTime,
      # Start the Telemetry supervisor
      HowhowSpeakWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: HowhowSpeak.PubSub},
      # Start the Endpoint (http/https)
      HowhowSpeakWeb.Endpoint
      # Start a worker by calling: HowhowSpeak.Worker.start_link(arg)
      # {HowhowSpeak.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HowhowSpeak.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HowhowSpeakWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
