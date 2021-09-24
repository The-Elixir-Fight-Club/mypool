defmodule MyPool.NodeQueue do
  use GenServer

  alias MyPool.PoolQueue
  alias MyPool.Worker.{Sum, Sub}

  def start_link(name: name) do
    GenServer.start_link(__MODULE__, [], name: name)
  end

  @impl true
  def init([]) do
    :net_kernel.monitor_nodes(true)
    {:ok, %{nodes: []}}
  end

  @impl true
  def handle_info({:nodeup, node}, %{nodes: nodes}) do
    # load worker sum and sub into remote node
    :c.nl(Sum)
    :c.nl(Sub)

    # add process to pool
    :ok = PoolQueue.add_remote_pid(PoolSum, node, 3)
    :ok = PoolQueue.add_remote_pid(PoolSub, node, 3)

    {:noreply, %{nodes: nodes ++ [node]}}
  end

  @impl true
  def handle_info({:nodedown, node}, %{nodes: nodes}) do
    {:noreply, %{nodes: nodes -- [node]}}
  end 
end
