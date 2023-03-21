defmodule ZeroWeb.FiltersLiveTest do
  use ZeroWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "Index" do
    test "lists active creator filter", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/filters")

      assert html =~ "Creator:"
    end
  end
end
