defmodule SoulGut.Repo.Migrations.Locations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name,    :text
      add :images,  {:array, :text}
      add :lat,     :decimal
      add :lon,     :decimal

      timestamps
    end
  end
end
