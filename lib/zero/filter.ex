defmodule Zero.Filter do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> "" end, name: __MODULE__)
  end

  def creator do
    Agent.get(__MODULE__, & &1)
  end

  def creator(value) do
    Agent.update(__MODULE__, fn _ -> value end)
    value
  end
end
