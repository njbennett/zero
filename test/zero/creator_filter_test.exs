defmodule Zero.CreatorFilterTest do
  use ExUnit.Case, async: true
  alias Zero.CreatorFilter

  describe "filter" do
    setup do
      filter = "CreatorFilterTestEditor"
      ok = CreatorFilter.put("CreatorFilterTestEditor", "")
      {ok, filter: filter}
    end

    test "get/1 returns the value for that editor", %{filter: filter} do
      assert CreatorFilter.get(filter) == ""
    end

    test "put/2 sets the value for that editor", %{filter: filter} do
      assert CreatorFilter.put(filter, "") == :ok
    end

    test "we can get the value we set", %{filter: filter} do
      :ok = CreatorFilter.put(filter, "Filter")
      assert CreatorFilter.get(filter) == "Filter"
    end
  end
end
