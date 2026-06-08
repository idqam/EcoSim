defmodule Ecosystem.Organism do
  use GenServer

  alias Ecosystem.Events.{OrganismMoved, OrganismDied}
  alias Ecosystem.EventBus

  # CLIENT API
  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def tick(pid) do
    GenServer.cast(pid, :tick)
  end

  # SERVER

  def init(state) do
    {:ok, state}
  end

  def handle_cast(:tick, state) do
    {new_state, events} = simulate(state)

    # emit asynchronously (important!)
    Enum.each(events, &EventBus.emit/1)

    {:noreply, new_state}
  end

  defp simulate(state) do
    # example movement logic
    old_pos = state.position
    new_pos = move_random(old_pos)

    event = %OrganismMoved{
      id: state.id,
      from: old_pos,
      to: new_pos,
      ts: System.system_time(:millisecond)
    }

    {
      %{state | position: new_pos},
      [event]
    }
  end

  defp move_random({x, y}) do
    {x + Enum.random(-1..1), y + Enum.random(-1..1)}
  end
end
