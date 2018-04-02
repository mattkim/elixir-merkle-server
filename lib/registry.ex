defmodule MerkleWordServer.Registry do
    use GenServer
  
    alias MerkleWordServer.Blocks, as: Blocks
    alias MerkleWordServer.Merkle, as: Merkle

    ## Client API
  
    @doc """
    Starts the registry.
    """
    def start_link(opts) do
      GenServer.start_link(__MODULE__, :ok, opts)
    end

    @doc """
    Create merkle tree with given list.
    """
    def create_merkle(l) do
        MerkleTree.new l
    end

    @doc """
    Create proof with given merkle tree and index.
    """
    def create_proof(mt, index) do
        # TODO: validate if index is out of array bounds.
        proof = MerkleTree.Proof.prove(mt, index)
        block = Enum.at(mt.blocks(), index)
        # combine hashes.
        hashes = Enum.join(proof.hashes)
        # use elem({},1) to get these back out.
        {block, index, hashes}
    end

    @doc """
    Call server to validate and add block.
    """
    def push(server, block, index, proof) do
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
        merkle = state.merkle
        blocks = state.blocks

        root = Merkle.get(merkle)

        if Merkle.proven?(block, index, root, proof) do
            Blocks.put(blocks, index, block)
            {:reply, {:ok, true}, state}
        else 
            {:reply, {:ok, false}, state}
        end
    end

    @doc """
    Get blocks.
    """
    def handle_call({:get_blocks}, _from, state) do
        # TODO: does this handle concurrency though?
        blocks = state.blocks
        expanded = Blocks.expand(Blocks.to_list(Blocks.get(blocks)))
        {:reply, {:ok, expanded}, state}
    end
  
    @doc """
    Reset merkle root to validate against.
    """
    def handle_call({:reset, root}, _from, state) do
        # TODO: Validate that root is correct size and type.
        merkle = state.merkle
        Merkle.set(merkle, root)
        {:reply, {:ok, root}, state}
    end
  end
