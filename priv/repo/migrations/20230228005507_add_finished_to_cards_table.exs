defmodule Zero.Repo.Migrations.AddFinishedToCardsTable do
  use Ecto.Migration

  def change do
    alter table(:cards) do
      add :finished, :boolean, default: false
    end
  end
end
