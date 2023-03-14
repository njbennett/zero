defmodule Zero.Lists.Card do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cards" do
    field :creators, :string
    field :details, :string
    field :name, :string
    field :victory_condition, :string
    field :finished, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:name, :details, :victory_condition, :finished, :inserted_at, :creators])
    |> validate_length(:name, max: 255)
    |> validate_length(:details, max: 255)
    |> validate_length(:victory_condition, max: 255)
    |> validate_length(:creators, max: 255)
    |> validate_required([:name, :details, :victory_condition])
  end
end
