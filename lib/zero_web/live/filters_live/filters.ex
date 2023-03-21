defmodule ZeroWeb.FiltersLive.Index do
  use ZeroWeb, :live_view

  alias Zero.Filter

  @impl true
  def render(assigns) do
    ~H"""
    <.table id="filters" rows={@creators}>
      <:col :let={creator} label="Use As"><%= elem(creator, 0) %></:col>
      <:col :let={creator} label="Creator"><%= elem(creator, 1) %></:col>
    </.table>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :creators, Filter.all_creators())}
  end
end
