defmodule EctoFdbRelational.Test.Post do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :integer, autogenerate: false}
  schema "posts" do
    field(:title, :string)
    field(:views, :integer)
    field(:published, :boolean)
  end
end
