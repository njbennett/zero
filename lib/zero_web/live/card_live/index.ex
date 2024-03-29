defmodule ZeroWeb.CardLive.Index do
  use ZeroWeb, :live_view

  alias Zero.Lists.Card
  alias Zero.Hexagon

  @impl true
  def mount(params, _session, socket) do
    ZeroWeb.Endpoint.subscribe("cards")
    ZeroWeb.Endpoint.subscribe("creator")
    ZeroWeb.Endpoint.subscribe("finished")

    {as, list, creator} = Hexagon.start_view(params)

    {:ok,
     socket
     |> assign(:as, as)
     |> assign(:list, list)
     |> assign(:creator, creator)
     |> assign(:creator_form_focused, false)
    }
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

  def handle_info(%{topic: "finished", event: "changed", payload: _as}, socket) do
    as = socket.assigns.as
    list = Hexagon.filtered_list(as)
    {:noreply, assign(socket, :list, list)}
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
    query = URI.encode_query(%{"use_as" => editor}, :www_form)

    {:noreply,
     socket
     |> assign(:list, list)
     |> assign(:creator, nil)
     |> assign(:as, editor)
     |> push_patch(to: "/cards?#{query}")}
  end

  @impl true
  def handle_event("toggle_show_finished", %{}, socket) do
    :ok = Hexagon.toggle_finished(socket.assigns.as)
    ZeroWeb.Endpoint.broadcast("finished", "changed", socket.assigns.as)

    {:noreply, socket}
  end

  def handle_event("focus-creator-button", %{}, socket) do
    {:noreply, assign(socket, :creator_form_focused, true)}
  end

  def handle_event("defocus-creator-button", %{}, socket) do
    {:noreply, assign(socket, :creator_form_focused, false)}
  end
end
