defmodule ZeroWeb.CardLiveTest do
  use ZeroWeb.ConnCase, async: true
  alias Zero.CreatorFilter

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

  defp start_index(conn) do
    live(conn, ~p"/cards?use_as=Setup+User")
  end

  describe "Index" do
    setup do
      CreatorFilter.put("Setup User", "")
      create_card(nil)
    end

    test "lists all cards", %{conn: conn, card: card} do
      {:ok, _index_live, html} = start_index(conn)

      assert html =~ "Listing Cards"
      assert html =~ card.details
      assert html =~ card.creators
    end

    test "filters cards by creator", %{conn: conn, card: card} do
      edgar_card = card_fixture(%{creators: "Edgar Friendly"})
      {:ok, index_live, html} = start_index(conn)

      assert html =~ "Filter by Creator"
      assert html =~ card.creators
      assert html =~ edgar_card.creators

      index_live
      |> form("#creator-filter-form", %{creator_filter: "Edgar"})
      |> render_change() =~ card.creators

      refute render(index_live) =~ card.creators
    end

    test "persists creator filter", %{conn: conn, card: card} do
      edgar_card = card_fixture(%{creators: "Edgar Friendly"})
      {:ok, index_live, html} = start_index(conn)

      assert html =~ "Filter by Creator"
      assert html =~ card.creators
      assert html =~ edgar_card.creators

      index_live
      |> form("#creator-filter-form", %{creator_filter: "Edgar"})
      |> render_change() =~ card.creators

      refute render(index_live) =~ card.creators

      {:ok, _, html} = start_index(conn)
      assert html =~ edgar_card.creators
      refute html =~ card.creators
    end

    test "persists creator after saving cards", %{conn: conn, card: card} do
      edgar_card = card_fixture(%{creators: "Edgar Friendly"})
      {:ok, index_live, _html} = start_index(conn)

      index_live
      |> form("#creator-filter-form", %{creator_filter: "Edgar"})
      |> render_change() =~ card.creators

      refute render(index_live) =~ card.creators

      assert index_live |> element("a", "New Card") |> render_click() =~
               "New Card"

      assert index_live
             |> form("#card-form", card: @create_attrs)
             |> render_submit()

      html = render(index_live)

      assert html =~ edgar_card.creators
      refute html =~ card.creators
    end

    test "only shows cards when Use As is filled", %{conn: conn, card: card} do
      {:ok, index_live, _html} = start_index(conn)

      index_live
      |> form("#use-as-form", %{use_as: ""})
      |> render_submit()

      refute render(index_live) =~ card.creators
    end

    test "sets Use As field from params", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cards?use_as=A%20Single%20Dingo")

      assert render(index_live) =~ "A Single Dingo"
    end

    test "persists Use As value after changing the creator filter", %{conn: conn, card: _card} do
      {:ok, index_live, _html} = start_index(conn)

      index_live
      |> form("#use-as-form", %{use_as: "John Spartan"})
      |> render_submit()

      index_live
      |> form("#creator-filter-form", %{creator_filter: "Edgar"})
      |> render_change()

      assert render(index_live) =~ "John Spartan"
    end

    test "sets the use_as url param when we click Manifest As", %{conn: conn} do
      {:ok, index_live, _html} = start_index(conn)

      index_live
      |> form("#use-as-form", %{use_as: "set param test user"})
      |> render_submit()

      assert_patch(index_live, ~p"/cards?use_as=set+param+test+user")
    end

    test "hides finished cards", %{conn: conn} do
      finished_card = card_fixture(%{finished: true, name: "finished card"})
      {:ok, index_live, _html} = start_index(conn)

      refute index_live |> element("#cards-#{finished_card.id}") |> has_element?()
    end

    test "saves new card", %{conn: conn} do
      {:ok, index_live, _html} = start_index(conn)

      assert index_live |> element("a", "New Card") |> render_click() =~
               "New Card"

      assert_patch(index_live, ~p"/cards/new")

      assert index_live
             |> form("#card-form", card: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#card-form", card: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/cards?use_as=Setup+User")
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

      {:ok, live_sender, _html} = start_index(conn)
      {:ok, live_reciever, _html} = start_index(conn)

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

      {:ok, live_sender, _html} = start_index(conn)
      {:ok, live_reciever, _html} = start_index(conn)

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

    test "changing a creator filter in one session should change it in all sessions", %{
      conn: conn
    } do
      {:ok, live_sender, _html} = start_index(conn)
      {:ok, live_reciever, _html} = start_index(conn)

      refute render(live_reciever) =~ "Edgar"

      live_reciever
      |> form("#creator-filter-form", %{creator_filter: "Edgar"})
      |> render_change() =~ "Edgar"

      assert render(live_reciever) =~ "Edgar"
      assert render(live_sender) =~ "Edgar"
    end

    test "only synchronizes creator filter in sessions that share a Use As", %{
      conn: conn
    } do
      {:ok, live_sender, _html} = start_index(conn)
      {:ok, live_reciever, _html} = start_index(conn)

      refute render(live_reciever) =~ "Edgar"

      live_reciever
      |> form("#use-as-form", %{use_as: "Ollie"})
      |> render_submit()

      live_sender
      |> form("#creator-filter-form", %{creator_filter: "Edgar"})
      |> render_change() =~ "Edgar"

      refute render(live_reciever) =~ "Edgar"
      assert render(live_sender) =~ "Edgar"
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
