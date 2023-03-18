defmodule Zero.FilterTest do
  use ExUnit.Case
  alias Zero.Filter

  describe "filter" do
    setup do
      {:ok, filter: Filter.creator("")}
    end

    test "returns its starting value" do
      assert Filter.creator() == ""
    end

    test "returns values that have been set" do
      assert Filter.creator("Edgar") == "Edgar"
    end

    test "persists values" do
      Filter.creator("Edgar")
      assert Filter.creator() == "Edgar"
    end
  end
end
