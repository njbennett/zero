defmodule Zero.HexagonTest do
  use Zero.DataCase, async: true
  alias Zero.Hexagon

  import Zero.ListsFixtures

  test "filtered_list/1 returns only unfinished cards by default" do
    _finished_card = card_fixture(%{finished: true})
    unfinished_card = card_fixture(%{finished: false})

    assert Hexagon.filtered_list("only_unfinished_editor") == [unfinished_card]
  end

  test "toggle_finished/1 sets the finished filter for a use_as" do
    assert Hexagon.toggle_finished("sets_the_finished_filter_editor") == :ok
  end

  test "the first time we call toggle_finished/1, filtered_list/1 returns all cards" do
    finished_card = card_fixture(%{finished: true})
    unfinished_card = card_fixture(%{finished: false})

    Hexagon.toggle_finished("first_toggle_editor")
    assert Hexagon.filtered_list("first_toggle_editor") == [finished_card, unfinished_card]
  end

  test "when we call toggle_finished/1 twice,, filtered_list/1 returns just unfinished cards again" do
    _finished_card = card_fixture(%{finished: true})
    unfinished_card = card_fixture(%{finished: false})

    Hexagon.toggle_finished("second_toggle_editor")
    Hexagon.toggle_finished("second_toggle_editor")
    assert Hexagon.filtered_list("second_toggle_editor") == [unfinished_card]
  end
end
