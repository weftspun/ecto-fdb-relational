defmodule EctoFdbRelational.Test.Repo do
  @moduledoc """
  Only used by `test/ecto_fdb_relational/integration_test.exs`, which is
  skipped unless `FRL_TEST_PORT` (and optionally `FRL_TEST_HOST`,
  `FRL_TEST_DATABASE`) point at a real running `fdb-relational-server` +
  FoundationDB cluster. See the README "Running the integration tests"
  section for how to stand one up (Maven Central artifacts, no source
  build needed -- verified working this session).
  """
  use Ecto.Repo,
    otp_app: :ecto_fdb_relational,
    adapter: EctoFdbRelational.Adapter
end
