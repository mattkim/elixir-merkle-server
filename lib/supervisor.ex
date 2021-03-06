defmodule MerkleWordServer.Supervisor do
    use Supervisor
  
    alias MerkleWordServer.Registry, as: Registry

    def start_link(opts) do
      Supervisor.start_link(__MODULE__, :ok, opts)
    end
  
    def init(:ok) do
      children = [
        {Registry, name: Registry}
      ]
  
      Supervisor.init(children, strategy: :one_for_one)
    end
end
