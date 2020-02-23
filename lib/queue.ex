defmodule Queue do
  use GenServer

  def start_link(default, name) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name)
  end

  # client function
  def push(pid, element) do
    GenServer.cast(pid, {:push, element})
  end

  def pop(pid) do
      GenServer.call(pid, :pop)
  end

  # Server (callbacks)
  @impl true
  def init(stack) do
    {:ok, stack}
  end

  @impl true
  def handle_call(:pop, _from, queue) do
      IO.puts("pop cb")
      if length(queue) > 0 do
        [head | tail] = queue
        {:reply, head, tail}
      else
        {:reply, :empty, :empty}
      end
  end

  @impl true
  def handle_cast({:push, element}, state) do
    IO.puts("push cb")
    {:noreply, [element | state]}
  end
  
end
