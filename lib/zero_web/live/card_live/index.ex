defmodule ZeroWeb.CardLive.Index do
  use ZeroWeb, :live_view

  alias Zero.Lists.Card
  alias Zero.Hexagon

  @impl true
  def mount(params, _session, socket) do
    ZeroWeb.Endpoint.subscribe("cards")
    ZeroWeb.Endpoint.subscribe("creator")

    {as, list, creator} = Hexagon.start_view(params)

    {:ok,
     socket
     |> assign(:as, as)
     |> assign(:list, list)
     |> assign(:creator, creator)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Card")
    |> assign(:card, Hexagon.get_card!(id))
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
    as = socket.assigns.as
    {:noreply, assign(socket, :list, Hexagon.filtered_list(as))}
  end

  def handle_info(%{topic: "creator", event: "changed", payload: _as}, socket) do
    {list, creator} = Hexagon.update_manifestor(socket.assigns.as)

    {:noreply,
     assign(socket, :list, list)
     |> assign(:creator, creator)}
  end

  @impl true
  def handle_event("change_filter", %{"creator_filter" => filter}, socket) do
    :ok = Hexagon.creator(socket.assigns.as, filter)
    ZeroWeb.Endpoint.broadcast("creator", "changed", socket.assigns.as)
    {:noreply, socket}
  end

  @impl true
  def handle_event("use_as", %{"use_as" => editor}, socket) do
    {list, _creator} = Hexagon.update_manifestor(editor)

    {:noreply,
     socket
     |> assign(:list, list)
     |> assign(:creator, nil)
     |> assign(:as, editor)}
  end
end
