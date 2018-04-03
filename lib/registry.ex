defmodule MerkleWordServer.Registry do
    use GenServer
  
    alias MerkleWordServer.Blocks, as: Blocks
    alias MerkleWordServer.Merkle, as: Merkle
    alias MerkleWordServer.Validator, as: Validator

    ## Client API
  
    @doc """
    Starts the registry.
    """
    def start_link(opts) do
      GenServer.start_link(__MODULE__, :ok, opts)
    end

    @doc """
    Call server to validate and add block.
    """
    def push(server, block, index, proof) do
        Validator.validate_index(index)
        Validator.validate_proof(proof)
        GenServer.call(server, {:push, block, index, proof})
    end
  
    @doc """
    Call server to get blocks.
    """
    def get_blocks(server) do
      GenServer.call(server, {:get_blocks})
    end
  
    @doc """
    Call server to reset merkle root.
    """
    def reset(server, root) do
      Validator.validate_root(root)
      GenServer.call(server, {:reset, root})
    end
  
    ## Server Callbacks

    @doc """
    Init gen server.  Stores one Merkle and Block agent for this gen server.
    """
    def init(:ok) do
      {:ok, merkle} = Merkle.start_link([])
      {:ok, blocks} = Blocks.start_link([])
      {:ok, %{
          :merkle => merkle,
          :blocks => blocks,
      }}
    end
  
    @doc """
    Validate and add block to blocks.
    """
    def handle_call({:push, block, index, proof}, _from, state) do
        Validator.validate_index(index)
        Validator.validate_proof(proof)
        
        merkle = state.merkle
        blocks = state.blocks

        root = Merkle.get(merkle)

        cond do
            Merkle.proven?(block, index, root, proof) ->
                Blocks.put(blocks, index, block)
                {:reply, {:ok, true}, state}
            true ->
                {:reply, {:ok, false}, state}
        end
    end

    @doc """
    Get blocks.
    """
    def handle_call({:get_blocks}, _from, state) do
        blocks = state.blocks
        expanded = Blocks.expand(Blocks.to_list(Blocks.get(blocks)))
        {:reply, {:ok, expanded}, state}
    end
  
    @doc """
    Reset merkle root to validate against.
    """
    def handle_call({:reset, root}, _from, state) do
        Validator.validate_root(root)
        merkle = state.merkle
        Merkle.set(merkle, root)
        {:reply, {:ok, root}, state}
    end
  end
