defmodule Zero.FilterTest do
  use ExUnit.Case
  alias Zero.Filter

  describe "filter" do

    test "returns its starting value" do
      assert Filter.creator() == ""
    end
  end
end
