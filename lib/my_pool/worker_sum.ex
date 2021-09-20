defmodule MyPool.Worker.Sum do
  use GenServer

  def start_link([]), do: GenServer.start_link(__MODULE__, [])

  @impl true
  def init(_) do
    {:ok, []}
  end

  @impl true
  def handle_call({:operation, a, b}, _from, _state) do
    IO.inspect("SUM VALUES #{a}, #{b} WAS PROCESSED BY #{inspect(self())}")
    {:reply, {:ok, a + b}, [a + b]}
  end
end
