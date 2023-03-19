defmodule ZeroWeb.CardLive.Index do
  use ZeroWeb, :live_view

  alias Zero.Lists
  alias Zero.Lists.Card
  alias Zero.Filter

  @impl true
  def mount(_params, _session, socket) do
    ZeroWeb.Endpoint.subscribe("cards")
    ZeroWeb.Endpoint.subscribe("creator")

    {:ok,
     socket
     |> assign(:as, "")
     |> assign(:list, Lists.list_cards_as(""))
     |> assign(:creator, Filter.creator())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Card")
    |> assign(:card, Lists.get_card!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Card")
    |> assign(:card, %Card{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Cards")
    |> assign(:card, nil)
  end

  @impl true
  def handle_info({ZeroWeb.CardLive.FormComponent, {:saved, card}}, socket) do
    ZeroWeb.Endpoint.broadcast("cards", "saved", card)
    {:noreply, socket}
  end

  def handle_info(%{topic: "cards", event: "saved", payload: _card}, socket) do
    {:noreply, assign(socket, :list, Lists.list_cards_as(Filter.creator(), socket.assigns.as))}
  end

  def handle_info(%{topic: "creator", event: "changed", payload: filter}, socket) do
    Filter.creator(filter)

    {:noreply,
     assign(socket, :list, Lists.list_cards_as(filter, socket.assigns.as))
     |> assign(:creator, filter)}
  end

  @impl true
  def handle_event("change_filter", %{"creator_filter" => filter}, socket) do
    ZeroWeb.Endpoint.broadcast("creator", "changed", filter)
    {:noreply, socket}
  end

  def handle_event("use_as", %{"use_as" => editor}, socket) do
    {:noreply,
     socket
     |> assign(:list, Lists.list_cards_as(Filter.creator(), editor))
     |> assign(:as, editor)}
  end
end
