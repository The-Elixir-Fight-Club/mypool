defmodule MyPool.PoolQueue do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: PoolQueue)
  end

  @impl true
  def init([]) do
    # our queue when our process start is always empty it means an empty list
    {:ok, []}
  end

  @impl true
  def handle_call(:get, _from, queue), do: {:reply, {:ok, queue}, queue}

  @impl true
  def handle_call(:get_pid, _from, [pid | queue]), do: {:reply, {:ok, pid}, queue ++ [pid]}

  @impl true
  def handle_cast({:in, pid}, queue), do: {:noreply, queue ++ [pid]}
end
