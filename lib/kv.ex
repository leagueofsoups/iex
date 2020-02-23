defmodule KV do
  use GenServer

  def start_link(default, name) when is_map(default) do
    GenServer.start_link(__MODULE__, default, name)
  end

  # client function
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
