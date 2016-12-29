defmodule SoulGut.Service do
  use Ecto.Schema
  import Ecto.Changeset
  use Timex.Ecto.Timestamps

  schema "services" do
    field :name,          :string, unique: true
    field :enabled,       :boolean, default: false
    field :client_id,     :string
    field :client_secret, :string
    field :access_token,  :string
    field :expires_at,    Timex.Ecto.DateTime
    field :refresh_token, :string

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w(enabled client_id client_secret access_token expires_at refresh_token)

  def changeset(service, params \\ :empty) do
    service
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:name)
  end

  def update_changeset(service, params \\ :empty) do
    service
    |> cast(params, [:id], @required_fields ++ @optional_fields)
    |> unique_constraint(:name)
  end
end
