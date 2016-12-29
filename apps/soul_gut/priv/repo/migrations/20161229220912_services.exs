defmodule SoulGut.Repo.Migrations.Services do
  use Ecto.Migration

  def change do
    alter table(:services) do
      add :enabled, :boolean, default: false
    end
  end
end
