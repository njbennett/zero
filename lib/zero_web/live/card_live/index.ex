defmodule ZeroWeb.CardLive.Index do
  use ZeroWeb, :live_view

  alias Zero.Lists
  alias Zero.Lists.Card

  @impl true
  def mount(_params, _session, socket) do
    ZeroWeb.Endpoint.subscribe("cards")
    {:ok, socket
      |> assign(:list, Lists.list_cards())
      |> stream(:cards, Lists.list_cards())}
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
    ZeroWeb.Endpoint.broadcast_from(self(), "cards", "saved", card)
    {:noreply, assign(socket, :list, Lists.list_cards())}
  end

  def handle_info(%{topic: "cards", event: "saved", payload: _card}, socket) do
    {:noreply, assign(socket, :list, Lists.list_cards())}
  end
end
