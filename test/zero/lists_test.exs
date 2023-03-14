defmodule Zero.ListsTest do
  use Zero.DataCase

  alias Zero.Lists

  describe "cards" do
    alias Zero.Lists.Card

    import Zero.ListsFixtures

    @invalid_attrs %{details: nil, name: nil, victory_condition: nil}
    @valid_attrs %{details: "some details", name: "some name", victory_condition: "some victory_condition", creators: "Edgar Friendly"}

    test "list_cards/0 returns all cards" do
      card = card_fixture()
      assert Lists.list_cards() == [card]
    end

    test "list_cards/0 returns all cards in the order they were created" do
      first_time = NaiveDateTime.utc_now()
      second_time = first_time |> NaiveDateTime.add(1, :second)
      card2 = card_fixture(%{ inserted_at: second_time })
      card1 = card_fixture(%{ inserted_at: first_time })

      assert Lists.list_cards() == [card1, card2]
    end

    test "get_card!/1 returns the card with given id" do
      card = card_fixture()
      assert Lists.get_card!(card.id) == card
    end

    test "create_card/1 with valid data creates a card" do
      assert {:ok, %Card{} = card} = Lists.create_card(@valid_attrs)
      assert card.details == "some details"
      assert card.name == "some name"
      assert card.victory_condition == "some victory_condition"
      assert card.creators == "Edgar Friendly"
    end

    test "create_card/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lists.create_card(@invalid_attrs)
    end

    test "create_card/1 with :name longer than 255 returns an error" do
      attrs = Map.replace(@valid_attrs, :name, String.duplicate("a", 256))
      assert {:error, %Ecto.Changeset{}} = Lists.create_card(attrs)
    end

    test "create_card/1 with :details longer than 255 returns an error" do
      attrs = Map.replace(@valid_attrs, :details, String.duplicate("a", 256))
      assert {:error, %Ecto.Changeset{}} = Lists.create_card(attrs)
    end

    test "create_card/1 with :victory_condition longer than 255 returns an error" do
      attrs = Map.replace(@valid_attrs, :victory_condition, String.duplicate("a", 256))
      assert {:error, %Ecto.Changeset{}} = Lists.create_card(attrs)
    end

    test "create_card/1 with :creators longer than 255 returns an error" do
      attrs = Map.replace(@valid_attrs, :creators, String.duplicate("a", 256))
      assert {:error, %Ecto.Changeset{}} = Lists.create_card(attrs)
    end

    test "update_card/2 with valid data updates the card" do
      card = card_fixture()
      update_attrs = %{details: "some updated details", name: "some updated name", victory_condition: "some updated victory_condition"}

      assert {:ok, %Card{} = card} = Lists.update_card(card, update_attrs)
      assert card.details == "some updated details"
      assert card.name == "some updated name"
      assert card.victory_condition == "some updated victory_condition"
    end

    test "update_card/2 with invalid data returns error changeset" do
      card = card_fixture()
      assert {:error, %Ecto.Changeset{}} = Lists.update_card(card, @invalid_attrs)
      assert card == Lists.get_card!(card.id)
    end

    test "delete_card/1 deletes the card" do
      card = card_fixture()
      assert {:ok, %Card{}} = Lists.delete_card(card)
      assert_raise Ecto.NoResultsError, fn -> Lists.get_card!(card.id) end
    end

    test "change_card/1 returns a card changeset" do
      card = card_fixture()
      assert %Ecto.Changeset{} = Lists.change_card(card)
    end
  end
end
