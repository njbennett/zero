defmodule Zero.Repo.Migrations.AddCreatorsToCards do
  use Ecto.Migration

  def change do
    alter table(:cards) do
      add :creators, :string
    end
  end
end
