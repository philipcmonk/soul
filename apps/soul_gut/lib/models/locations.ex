defmodule SoulGut.Locations do
  use Ecto.Schema
  import Ecto.Changeset
  use Timex.Ecto.Timestamps

  schema "events" do
    field :name,    :string
    field :images,  {:array, :string}
    field :lat,     :decimal
    field :lon,     :decimal

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w(images lat lon)

  def changeset(service, params \\ :empty) do
    service
    |> cast(params, @required_fields, @optional_fields)
  end
end
