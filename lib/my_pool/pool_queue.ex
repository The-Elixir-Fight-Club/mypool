defmodule MyPool.PoolQueue do
  use GenServer

  require Logger

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
    Process.flag(:trap_exit, true)

    queue =
      1..n
      |> Enum.to_list()
      |> Enum.map(fn _n ->
        {:ok, pid} = :erlang.apply(mod, fun, [args])

        ref = :erlang.monitor(:process, pid)

        %{pid: pid, ref: ref}
      end)

    {:ok, %{queue: queue, worker: {mod, fun, args}}}
  end

  @impl true
  def handle_call(:get, _from, %{queue: queue} = state), do: {:reply, {:ok, queue}, state}

  @impl true
  def handle_call(:get_pid, _from, %{queue: [%{pid: pid} = pid_ref | queue], worker: worker}),
    do: {:reply, {:ok, pid}, %{queue: queue ++ [pid_ref], worker: worker}}

  @impl true
  def handle_cast({:in, pid}, %{queue: queue, worker: worker}) do
    ref = :erlang.monitor(:process, pid)

    {:noreply, %{queue: queue ++ [%{pid: pid, ref: ref}], worker: worker}}
  end

  @impl true
  def handle_cast({:join, node}, %{queue: queue, worker: worker}) do
    pid = Node.spawn(node, MyPool.Worker.Sum, :start_link, [[]])
    # ref = :erlang.monitor(:process, pid)
    ref = nil
    IO.inspect(pid)
    {:noreply, %{queue: queue ++ [%{pid: pid, ref: ref}], worker: worker}}
  end

  @impl true
  def handle_info(
        {:DOWN, _ref, :process, pid, _reason},
        %{queue: queue, worker: {mod, fun, args}} = state
      ) do
    IO.inspect(binding())

    Enum.find(queue, fn %{pid: n_pid} -> n_pid == pid end)
    |> case do
      nil ->
        Logger.warn("pid #{inspect(pid)} was not foun in queue, ignoring ...")

        {:noreply, state}

      %{pid: _pid, ref: _ref} = elem ->
        Logger.info("pid #{inspect(pid)} was DOWN, replacing in queue for another instance")

        {:ok, new_pid} = :erlang.apply(mod, fun, [args])

        ref = :erlang.monitor(:process, new_pid)

        queue =
          queue
          |> Kernel.--([elem])
          |> Kernel.++([%{pid: new_pid, ref: ref}])

        {:noreply, %{queue: queue, worker: {mod, fun, args}}}
    end
  end

  def handle_info({:EXIT, _pid, _reason}, state), do: {:noreply, state}

  def handle_info(_msg, state) do
    IO.puts("----------------------------------------------------")
    IO.inspect(binding())
    IO.puts("----------------------------------------------------")
    {:noreply, state}
  end
end
