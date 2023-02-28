defmodule Zero.Lists.Card do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cards" do
    field :details, :string
    field :name, :string
    field :victory_condition, :string
    field :finished, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:name, :details, :victory_condition, :finished, :inserted_at])
    |> validate_required([:name, :details, :victory_condition])
  end
end
