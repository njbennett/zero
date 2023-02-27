defmodule Zero.ListsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Zero.Lists` context.
  """

  @doc """
  Generate a card.
  """
  def card_fixture(attrs \\ %{}) do
    {:ok, card} =
      attrs
      |> Enum.into(%{
        details: "some details",
        name: "some name",
        victory_condition: "some victory_condition"
      })
      |> Zero.Lists.create_card()

    card
  end
end
