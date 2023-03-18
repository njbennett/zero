defmodule ZeroWeb.CardLiveTest do
  use ZeroWeb.ConnCase
  alias Zero.Filter

  import Phoenix.LiveViewTest
  import Zero.ListsFixtures

  @create_attrs %{
    details: "some details",
    name: "some name",
    victory_condition: "some victory_condition",
    creators: "Some Creator"
  }
  @update_attrs %{
    details: "some updated details",
    name: "some updated name",
    victory_condition: "some updated victory_condition",
    creators: "Some Updated Creator"
  }
  @invalid_attrs %{details: nil, name: nil, victory_condition: nil, creators: nil}
  @finish_attrs %{
    details: "some details",
    name: "some name",
    victory_condition: "some victory_condition",
    finished: true,
    creators: "Some Creator"
  }

  defp create_card(_) do
    card = card_fixture()
    %{card: card}
  end

  describe "Index" do
    setup do
      Filter.creator("")
      create_card(nil)
    end

    test "lists all cards", %{conn: conn, card: card} do
      {:ok, _index_live, html} = live(conn, ~p"/cards")

      assert html =~ "Listing Cards"
      assert html =~ card.details
      assert html =~ card.creators
    end

    test "filters cards by creator", %{conn: conn, card: card} do
      edgar_card = card_fixture(%{creators: "Edgar Friendly"})
      {:ok, index_live, html} = live(conn, ~p"/cards")

      assert html =~ "Filter by Creator"
      assert html =~ card.creators
      assert html =~ edgar_card.creators

      refute index_live
             |> form("#creator-filter-form", %{creator_filter: "Edgar"})
             |> render_change() =~ card.creators
    end

    test "persists creator filter", %{conn: conn, card: card} do
      edgar_card = card_fixture(%{creators: "Edgar Friendly"})
      {:ok, index_live, html} = live(conn, ~p"/cards")

      assert html =~ "Filter by Creator"
      assert html =~ card.creators
      assert html =~ edgar_card.creators

      refute index_live
             |> form("#creator-filter-form", %{creator_filter: "Edgar"})
             |> render_change() =~ card.creators

      {:ok, _, html} = live(conn, ~p"/cards")
      assert html =~ edgar_card.creators
      refute html =~ card.creators
    end

    test "persists creator after saving cards", %{conn: conn, card: card} do
      edgar_card = card_fixture(%{creators: "Edgar Friendly"})
      {:ok, index_live, _html} = live(conn, ~p"/cards")

      refute index_live
             |> form("#creator-filter-form", %{creator_filter: "Edgar"})
             |> render_change() =~ card.creators

      assert index_live |> element("a", "New Card") |> render_click() =~
               "New Card"

      assert index_live
             |> form("#card-form", card: @create_attrs)
             |> render_submit()

      html = render(index_live)

      assert html =~ edgar_card.creators
      refute html =~ card.creators
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

    test "shows cards created in other LiveView sessions immediately", %{conn: conn} do
      card_attrs = %{
        details: "bees",
        name: "bees",
        victory_condition: "bees",
        creators: "Bees! Bees!"
      }

      {:ok, live_sender, _html} = live(conn, ~p"/cards")
      {:ok, live_reciever, _html} = live(conn, ~p"/cards")

      live_sender
      |> element("a", "New Card")
      |> render_click()

      live_sender
      |> form("#card-form", card: card_attrs)
      |> render_submit()

      html = render(live_reciever)
      assert html =~ "Bees! Bees!"
    end

    test "persists creator filter when it recieves a broadast", %{conn: conn} do
      card_attrs = %{
        details: "bees",
        name: "bees",
        victory_condition: "bees",
        creators: "Bees! Bees!"
      }

      {:ok, live_sender, _html} = live(conn, ~p"/cards")
      {:ok, live_reciever, _html} = live(conn, ~p"/cards")

      refute live_reciever
             |> form("#creator-filter-form", %{creator_filter: "Edgar"})
             |> render_change() =~ "Bees! Bees!"

      live_sender
      |> element("a", "New Card")
      |> render_click()

      live_sender
      |> form("#card-form", card: card_attrs)
      |> render_submit()

      html = render(live_reciever)
      refute html =~ "Bees! Bees!"
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
