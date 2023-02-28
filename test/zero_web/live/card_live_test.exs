defmodule ZeroWeb.CardLiveTest do
  use ZeroWeb.ConnCase

  import Phoenix.LiveViewTest
  import Zero.ListsFixtures

  @create_attrs %{details: "some details", name: "some name", victory_condition: "some victory_condition"}
  @update_attrs %{details: "some updated details", name: "some updated name", victory_condition: "some updated victory_condition"}
  @invalid_attrs %{details: nil, name: nil, victory_condition: nil}
  @finish_attrs %{details: "some details", name: "some name", victory_condition: "some victory_condition", finished: true}

  defp create_card(_) do
    card = card_fixture()
    %{card: card}
  end

  describe "Index" do
    setup [:create_card]

    test "lists all cards", %{conn: conn, card: card} do
      {:ok, _index_live, html} = live(conn, ~p"/cards")

      assert html =~ "Listing Cards"
      assert html =~ card.details
    end

    test "saves new card", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cards")

      assert index_live |> element("a", "New Card") |> render_click() =~
               "New Card"

      assert_patch(index_live, ~p"/cards/new")

      assert index_live
             |> form("#card-form", card: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#card-form", card: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/cards")

      html = render(index_live)
      assert html =~ "Card created successfully"
      assert html =~ "some details"
    end

    test "updates card in listing", %{conn: conn, card: card} do
      {:ok, index_live, _html} = live(conn, ~p"/cards")

      assert index_live |> element("#cards-#{card.id} a", "Edit") |> render_click() =~
               "Edit Card"

      assert_patch(index_live, ~p"/cards/#{card}/edit")

      assert index_live
             |> form("#card-form", card: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#card-form", card: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/cards")

      html = render(index_live)
      assert html =~ "Card updated successfully"
      assert html =~ "some updated details"
    end

    test "deletes card in listing", %{conn: conn, card: card} do
      {:ok, index_live, _html} = live(conn, ~p"/cards")

      assert index_live |> element("#cards-#{card.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#cards-#{card.id}")
    end
  end

  describe "Show" do
    setup [:create_card]

    test "displays card", %{conn: conn, card: card} do
      {:ok, _show_live, html} = live(conn, ~p"/cards/#{card}")

      assert html =~ "Show Card"
      assert html =~ card.details
    end

    test "updates card within modal", %{conn: conn, card: card} do
      {:ok, show_live, _html} = live(conn, ~p"/cards/#{card}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Card"

      assert_patch(show_live, ~p"/cards/#{card}/show/edit")

      assert show_live
             |> form("#card-form", card: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#card-form", card: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/cards/#{card}")

      html = render(show_live)
      assert html =~ "Card updated successfully"
      assert html =~ "some updated details"
    end
  end

  describe "Edit" do
    setup [:create_card]

    test "finishes a card", %{conn: conn, card: card} do
      {:ok, show_live, _html} = live(conn, ~p"/cards/#{card}")

      assert show_live |> element("a", "Edit") |> render_click() =~
      "Edit Card"

      html = render(show_live)
      assert html =~ "Finish"

      assert_patch(show_live, ~p"/cards/#{card}/show/edit")

      assert show_live
             |> form("#card-form", card: @finish_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/cards/#{card}")

      html = render(show_live)
      assert html =~ "Finished"
      assert html =~ "true"
    end
  end
end
