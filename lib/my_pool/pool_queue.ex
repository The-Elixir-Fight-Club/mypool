defmodule MyPool.PoolQueue do
  use GenServer

  def start_link(worker: {mod, fun, args}, n_workers: n, name: name) do
    GenServer.start_link(__MODULE__, [{mod, fun, args}, n], name: name)
  end

  def get(name), do: GenServer.call(name, :get)

  def get_pid(name), do: GenServer.call(name, :get_pid)

  #def add_pid() do
  #  {:ok, pid} = :erlang.apply(MyPool.Worker, :start_link, [[]])
  #  GenServer.cast(PoolQueue, {:in, pid})
  #end

  def exec(name, a, b) do
    {:ok, pid} = GenServer.call(name, :get_pid)
    GenServer.call(pid, {:operation, a, b})
  end

  @impl true
  def init([{mod, fun, args}, n]) do
    queue = 1..n
    |> Enum.to_list()
    |> Enum.map(fn _n ->
      {:ok, pid} = :erlang.apply(mod, fun, [args])
      pid
    end)
    # our queue when our process start is always empty it means an empty list
    {:ok, queue}
  end

  @impl true
  def handle_call(:get, _from, queue), do: {:reply, {:ok, queue}, queue}

  @impl true
  def handle_call(:get_pid, _from, [pid | queue]), do: {:reply, {:ok, pid}, queue ++ [pid]}

  @impl true
  def handle_cast({:in, pid}, queue), do: {:noreply, queue ++ [pid]}
end
