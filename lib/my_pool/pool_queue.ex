defmodule MyPool.PoolQueue do
  use GenServer

  def start_link(worker: {mod, fun, args}, n_workers: n, name: name) do
    GenServer.start_link(__MODULE__, [{mod, fun, args}, n], name: name)
  end

  def get(name), do: GenServer.call(name, :get)

  def get_pid(name), do: GenServer.call(name, :get_pid)

  def exec(name, a, b) do
    {:ok, pid} = GenServer.call(name, :get_pid)
    GenServer.call(pid, {:operation, a, b})
  end

  @impl true
  def init([{mod, fun, args}, n]) do
    queue =
      1..n
      |> Enum.to_list()
      |> Enum.map(fn _n ->
        {:ok, pid} = :erlang.apply(mod, fun, [args])

        ref = :erlang.monitor(:process, pid)

        %{pid: pid, ref: ref}
      end)
  end

  @impl true
  def handle_call(:get, _from, queue), do: {:reply, {:ok, queue}, queue}

  @impl true
  def handle_call(:get_pid, _from, [%{pid: pid} = pid_ref | queue]),
    do: {:reply, {:ok, pid}, queue ++ [pid_ref]}

  @impl true
  def handle_cast({:in, pid}, queue) do
    ref = :erlang.monitor(:process, pid)

    {:noreply, queue ++ [%{pid: pid, ref: ref}]}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, pid, _reason}, queue) do
    Enum.find(queue, fn %{pid: n_pid} -> n_pid == pid end)
    |> case do
      nil ->
        IO.inspect("not found pid")

      %{pid: pid, ref: ref} ->
        nil
    end
  end
end
