defmodule Zero.Filter do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def creator do
    Agent.get(__MODULE__, &Map.get(&1, ""))
  end

  def creator(value) do
    :ok = Agent.update(__MODULE__, &Map.put(&1, "", value))
    value
  end

  def creator_as(as, creator) do
    :ok = Agent.update(__MODULE__, &Map.put(&1, as, creator))
    creator
  end

  def creator_as(as) do
    Agent.get(__MODULE__, &Map.get(&1, as))
  end
end
