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
end
