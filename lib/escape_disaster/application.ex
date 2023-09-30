defmodule EscapeDisaster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      EscapeDisasterWeb.Telemetry,
      # Start the Ecto repository
      EscapeDisaster.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: EscapeDisaster.PubSub},
      # Start Finch
      {Finch, name: EscapeDisaster.Finch},
      # Start the Endpoint (http/https)
      EscapeDisasterWeb.Endpoint
      # Start a worker by calling: EscapeDisaster.Worker.start_link(arg)
      # {EscapeDisaster.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EscapeDisaster.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EscapeDisasterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
