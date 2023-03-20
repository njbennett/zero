defmodule Zero.Filter do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def creator do
    Agent.get(__MODULE__, &Map.get(&1, ""))
  end

  def creator(value) do
    Agent.update(__MODULE__, &Map.put(&1, "", value))
    value
  end
end
