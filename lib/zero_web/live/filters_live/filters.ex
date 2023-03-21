defmodule ZeroWeb.FiltersLive.Index do
  use ZeroWeb, :live_view

  alias Zero.Filter

  @impl true
  def render(assigns) do
    ~H"""
    <div>Creator:</div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :creator, Filter.creator())}
  end
end
