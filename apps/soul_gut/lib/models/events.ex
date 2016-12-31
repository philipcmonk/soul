defmodule SoulGut.Events do
  use Ecto.Schema
  import Ecto.Changeset
  use Timex.Ecto.Timestamps

  schema "events" do
    field :name,          :string
    field :orig_id,       :string
    field :images,        {:array, :string}
    field :date_recorded, Timex.Ecto.DateTime
    field :location,      :integer

    timestamps
  end

  @required_fields ~w(name orig_id location)
  @optional_fields ~w(images date_recorded)

  def changeset(service, params \\ %{}) do
    service
    |> cast(params, @required_fields, @optional_fields)
  end
end
