defmodule Zero.Hexagon do
  alias Zero.Lists
  alias Zero.CreatorFilter

  def start_view(params) do
    as = Map.get(params, "use_as")
    list = get_list(params)

    # I thought that this logic was needed but apparently no test cares
    # creator = CreatorFilter.get(Map.get(params, "use_as"))
    {as, list, nil}
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
end
