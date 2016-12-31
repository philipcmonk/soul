defmodule SoulGut.Repo.Migrations.Events do
  use Ecto.Migration
  use Timex.Ecto.Timestamps

  def change do
    create table(:events) do
      add :name,          :text
      add :service,       :text
      add :orig_id,       :text
      add :images,        {:array, :text}
      add :date_recorded, :datetime
      add :location,      :integer

      timestamps
    end
  end
end
