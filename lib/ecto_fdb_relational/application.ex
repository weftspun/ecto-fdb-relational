defmodule EctoFdbRelational.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Accumulates CREATE TABLE / CREATE INDEX DDL across a migration run,
      # since FRL's schema templates are declared holistically rather than
      # incrementally -- see EctoFdbRelational.SchemaTemplate for why.
      EctoFdbRelational.SchemaTemplate
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EctoFdbRelational.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
