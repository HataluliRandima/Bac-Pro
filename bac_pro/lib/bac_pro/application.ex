defmodule BacPro.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BacProWeb.Telemetry,
      BacPro.Repo,
      {Oban, Application.fetch_env!(:bac_pro, Oban)},
      {DNSCluster, query: Application.get_env(:bac_pro, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BacPro.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: BacPro.Finch},
      # Start a worker by calling: BacPro.Worker.start_link(arg)
      # {BacPro.Worker, arg},
      # Start to serve requests, typically the last entry
      BacProWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BacPro.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BacProWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
