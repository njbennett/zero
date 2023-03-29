defmodule Zero.FinishedFilter do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{Filter: ""} end, name: __MODULE__)
  end

  def toggle(key) do
    if Agent.get(__MODULE__, &Map.get(&1, key)) == nil do
      Agent.update(__MODULE__, &Map.put(&1, key, true))
    else
      value = Agent.get(__MODULE__, &Map.get(&1, key)) |> Kernel.not()
      Agent.update(__MODULE__, &Map.put(&1, key, value))
    end
  end

  def get(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end
end
