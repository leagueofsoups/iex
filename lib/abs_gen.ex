defmodule Abs_GenSrv do
  use GenServer

  def start_link(default, name) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name)
  end

  def start_link(default, name) when is_map(default) do
    GenServer.start_link(__MODULE__, default, name)
  end

  # client function
  def push(pid, element) do
    GenServer.cast(pid, {:push, element})
  end

  def pop(pid) do
      GenServer.call(pid, :pop)
  end

  def kv(pid, key, val) do
      GenServer.cast(pid, {:buket_update, key, val})
  end

  def get_key(pid, key) do
      GenServer.call(pid, {:get_key, key})
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

  def handle_cast({:buket_update, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  def handle_call({:get_key, key}, _, state) do
    if  Map.has_key?(state, key) do
      {:ok, val} = Map.fetch(state, key)
      {:reply, {:ok, val}, state}
    else
      {:reply, {:ok, 1}, %{}}
    end
  end

end
