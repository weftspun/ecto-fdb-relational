defmodule EctoFdbRelational.MixProject do
  use Mix.Project

  @version "0.3.0"
  @source_url "https://github.com/weftspun/ecto_fdb_relational"

  def project do
    [
      app: :ecto_fdb_relational,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      description: description(),
      package: package(),
      name: "EctoFdbRelational",
      source_url: @source_url,
      homepage_url: @source_url,
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      dialyzer: [
        plt_add_apps: [:ex_unit, :mix],
        flags: [:error_handling, :underspecs],
        ignore_warnings: ".dialyzer_ignore.exs"
      ]
    ]
  end

  def cli do
    [
      preferred_envs: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {EctoFdbRelational.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Ecto core + the SQL adapter toolkit (query building, migrations, DBConnection wiring)
      # that adapters such as ecto_sqlite3 and myxql build on top of.
      {:ecto, "~> 3.11"},
      {:ecto_sql, "~> 3.11"},
      {:db_connection, "~> 2.6"},

      # Wire codec only (no gRPC service/stub code -- see
      # lib/ecto_fdb_relational/proto/jdbc.pb.ex): FRL's own
      # grpc.relational.jdbc.v1.{StatementRequest,StatementResponse,...} messages, now
      # carried over JNI instead of gRPC/HTTP2. See ADR 0003.
      {:protobuf, "~> 0.13"},

      # Embeds FRL in-process via a Rustler NIF + JNI -- see ADR 0003 and
      # EctoFdbRelational.Native. Needs a Rust toolchain (to build native/
      # ecto_fdb_relational_nif) and a JDK (both to link against libjvm and, via
      # :frl_bridge above, to compile native/frl_bridge) wherever this is *compiled* --
      # see the README.
      {:rustler, "~> 0.38"},

      # Dev/test/docs tooling only.
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      {:propcheck, "~> 1.5", only: :test}
    ]
  end

  defp description do
    "An Ecto adapter for FoundationDB Record Layer's Relational Layer (FRL), " <>
      "embedding FRL in-process via a Rustler NIF + JNI (no separate fdb-relational-server " <>
      "process, no gRPC)."
  end

  defp package do
    [
      name: "ecto_fdb_relational",
      files:
        ~w(lib priv/protos native .formatter.exs mix.exs README.md CHANGELOG.md LICENSE ADR.md),
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "FoundationDB Record Layer (FRL)" => "https://github.com/FoundationDB/fdb-record-layer",
        "Changelog" => @source_url <> "/blob/main/CHANGELOG.md"
      },
      maintainers: ["weftspun"]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "ADR.md", "CHANGELOG.md"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
