defmodule MyPool.Worker.Sub do
  use GenServer

  require Logger

  def start_link([]), do: GenServer.start_link(__MODULE__, [])

  @impl true
  def init(_) do
    {:ok, []}
  end

  @impl true
  def handle_call({:operation, a, b}, _from, _state) do
    Logger.info("SUB VALUES #{a}, #{b} WAS PROCESSED BY #{inspect(self())}")
    {:reply, {:ok, a - b}, [a - b]}
  end
end
