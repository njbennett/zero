defmodule Zero.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:cards) do
      add :name, :string
      add :details, :string
      add :victory_condition, :string

      timestamps()
    end
  end
end
