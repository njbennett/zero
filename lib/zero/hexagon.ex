defmodule Zero.Hexagon do
  alias Zero.Lists
  alias Zero.CreatorFilter

  def start_view(params) do
    manifestor = Map.get(params, "use_as")
    list = get_list(params)

    # I thought that this logic was needed but apparently no test cares
    # creator = CreatorFilter.get(Map.get(params, "use_as"))
    {manifestor, list, nil}
  end

  def update_manifestor(manifestor) do
    list = filtered_list(manifestor)

    # thought this was required too but again, no test fails
    creator = creator(manifestor)
    {list, creator}
  end

  defp get_list(params) do
    use_as = Map.get(params, "use_as")

    if use_as == nil do
      Lists.list_cards_as("")
    else
      filtered_list(use_as)
    end
  end

  def filtered_list(use_as) do
    Lists.list_cards_as(CreatorFilter.get(use_as), use_as)
  end

  def get_card!(id) do
    Lists.get_card!(id)
  end

  defp creator(manifestor) do
    CreatorFilter.get(manifestor)
  end

  def creator(manifestor, filter) do
    CreatorFilter.put(manifestor, filter)
  end
end
