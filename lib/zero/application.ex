defmodule Zero.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    OpentelemetryPhoenix.setup()
    OpentelemetryLiveView.setup()
    OpentelemetryEcto.setup([:zero, :repo])
    children = [
      # Start the Telemetry supervisor
      ZeroWeb.Telemetry,
      # Start the Ecto repository
      Zero.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Zero.PubSub},
      # Start Finch
      {Finch, name: Zero.Finch},
      # Start the Endpoint (http/https)
      ZeroWeb.Endpoint,
      # Start a worker by calling: Zero.Worker.start_link(arg)
      # {Zero.Worker, arg}
      Zero.Filter
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Zero.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ZeroWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
