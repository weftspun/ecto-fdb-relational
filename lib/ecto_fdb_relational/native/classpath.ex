defmodule EctoFdbRelational.Native.Classpath do
  @moduledoc """
  Builds the classpath `EctoFdbRelational.Native`'s embedded JVM starts with -- kept in
  its own module, separate from `EctoFdbRelational.Native`, because it's called via that
  module's `load_data_fun` from *within* `@on_load`: Erlang won't let a module call back
  into its own functions from its own `on_load` hook (the module isn't registered as
  loaded yet at that point), so this has to live somewhere else.
  """

  @doc false
  @spec build() :: String.t()
  def build do
    external =
      System.get_env("ECTO_FDB_RELATIONAL_CLASSPATH") ||
        raise ArgumentError,
              "ECTO_FDB_RELATIONAL_CLASSPATH is not set. It must list the FRL jars " <>
                "(org.foundationdb:fdb-relational-server:<version>:all is enough on its own), " <>
                "colon-separated. See the README."

    bridge_classes = Path.join(:code.priv_dir(:ecto_fdb_relational), "java")

    Enum.join([external, bridge_classes], ":")
  end
end
