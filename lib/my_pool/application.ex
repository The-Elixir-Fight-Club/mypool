defmodule MyPool.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: MyPool.Worker.start_link(arg)
      Supervisor.child_spec({MyPool.PoolQueue,
        [worker: {MyPool.Worker.Sum, :start_link, []}, n_workers: 3, name: PoolSum]}, id: :worker_sum),
      Supervisor.child_spec({MyPool.PoolQueue,
        [worker: {MyPool.Worker.Sub, :start_link, []}, n_workers: 3, name: PoolSub]}, id: :worker_sub)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MyPool.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
