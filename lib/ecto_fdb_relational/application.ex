defmodule EctoFdbRelational.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Required by GRPC.Stub.connect/2 (grpc >= 0.11) -- it starts each
      # GRPC.Client.Connection as a child of this supervisor rather than
      # linking it to the caller.
      {GRPC.Client.Supervisor, []},
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
