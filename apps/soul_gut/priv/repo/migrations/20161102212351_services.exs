defmodule SoulGut.Repo.Migrations.Services do
  use Ecto.Migration
  use Timex.Ecto.Timestamps

  def change do
    create table(:services) do
      add :name,          :string, unique: true
      add :client_id,     :string
      add :client_secret, :string
      add :access_token,  :string
      add :expires_at,    :datetime
      add :refresh_token, :string

      timestamps
    end

    create unique_index(:services, [:name], name: :unique_names)
  end
end
