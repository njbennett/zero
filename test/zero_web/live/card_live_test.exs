defmodule ZeroWeb.CardLiveTest do
  use ZeroWeb.ConnCase

  import Phoenix.LiveViewTest
  import Zero.ListsFixtures

  @create_attrs %{details: "some details", name: "some name", victory_condition: "some victory_condition", creators: "Some Creator"}
  @update_attrs %{details: "some updated details", name: "some updated name", victory_condition: "some updated victory_condition", creators: "Some Updated Creator"}
  @invalid_attrs %{details: nil, name: nil, victory_condition: nil, creators: nil}
  @finish_attrs %{details: "some details", name: "some name", victory_condition: "some victory_condition", finished: true, creators: "Some Creator"}

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
      assert html =~ card.creators
    end

    test "hides finished cards", %{conn: conn} do
      finished_card = card_fixture(%{finished: true, name: "finished card"})
      {:ok, index_live, _html} = live(conn, ~p"/cards")

      # assert the finished card has the class "hidden"
      assert index_live |> element("#cards-#{finished_card.id}.hidden") |> has_element?()
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

    test "broadcasts cards created to other LiveView sessions", %{conn: conn} do
      # subscribe to a PubSub topic named "cards"
      ZeroWeb.Endpoint.subscribe("cards")

      card_attrs = %{details: "bees", name: "bees", victory_condition: "bees", creators: "Bees! Bees!"}

      {:ok, index_live, _html} = live(conn, ~p"/cards")

      assert index_live |> element("a", "New Card") |> render_click() =~
               "New Card"

      assert_patch(index_live, ~p"/cards/new")

      assert index_live
             |> form("#card-form", card: card_attrs)
             |> render_submit()

      assert_receive %{topic: "cards", event: "saved", payload: %Zero.Lists.Card{}}
    end

    test "adds a card to the view when it recieves a broadcast", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cards")

      ZeroWeb.Endpoint.broadcast_from(self(), "cards", "saved", card_fixture(%{name: "broadcasted card"}))
      _ = :sys.get_state(index_live.pid)

      html = render(index_live)
      assert html =~ "broadcasted card"
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
