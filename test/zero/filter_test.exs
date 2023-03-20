defmodule Zero.FilterTest do
  use ExUnit.Case, async: true
  alias Zero.Filter

  describe "filter" do
    setup do
      {:ok, filter: Filter.creator("")}
    end

    test "creator/0 returns its starting value" do
      assert Filter.creator() == ""
    end

    test "creator/1 returns values that have been set" do
      assert Filter.creator("Edgar") == "Edgar"
    end

    test "creator/1 persists values" do
      Filter.creator("Edgar")
      assert Filter.creator() == "Edgar"
    end

    test "creator_as/2 can store multiple values" do
      assert Filter.creator_as("Edgar", "Edgar") == "Edgar"
    end

    test "creator_as/1 returns the creator set for the provided key" do
      Filter.creator_as("Edgar", "Edgar")
      assert Filter.creator_as("Edgar") == "Edgar"
    end

    test "creator_as/2 can set creator to a different value than the key" do
      assert Filter.creator_as("Edgar", "Ollie") == "Ollie"
    end

    test "creator_as/2 persists values" do
      Filter.creator_as("Edgar", "Ollie")
      assert Filter.creator_as("Edgar") == "Ollie"
    end
  end
end
