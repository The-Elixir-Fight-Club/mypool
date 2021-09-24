defmodule MyPool.NodeMonitor do
  use GenServer

  require Logger

  def start_link([]), do: GenServer.start_link(__MODULE__, [])

  @impl true
  def init(_) do
    :ok = :net_kernel.monitor_nodes(true)
    Logger.info("Monitoring Nodes!!!")
    {:ok, []}
  end

  @impl true
  def handle_info({:nodeup, node}, state) do
    :abcast = :c.nl(MyPool.Worker.Sum)
    # pid = Node.spawn(node, MyPool.Worker.Sum, :start_link, [[]])
    # :ok = GenServer.cast(PoolSum, {:in, pid})

    :ok = GenServer.cast(PoolSum, {:join, node})

    Logger.info("Node up #{inspect(node)}")
    {:noreply, state}
  end

  def handle_info({:nodedown, node}, state) do
    Logger.info("Node Down #{inspect(node)}")
    {:noreply, state}
  end

  def handle_info(msg, state) do
    IO.inspect(binding())
    {:noreply, state}
  end
end
