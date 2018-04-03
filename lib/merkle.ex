defmodule MerkleWordServer.Merkle do
    use Agent

    alias MerkleWordServer.Validator, as: Validator

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
        blocks = mt.blocks()

        Validator.validate_index(index, length(blocks))

        proof = MerkleTree.Proof.prove(mt, index)
        block = Enum.at(blocks, index)
        # combine hashes.
        hashes = Enum.join(proof.hashes)
        # use elem({},1) to get these back out.
        {block, index, hashes}
    end

    @doc """
    Validate proof matches with merkle root.
    """
    def proven?(block, index, root, proof) do
        Validator.validate_index(index)
        Validator.validate_root(root)
        Validator.validate_proof(proof)

        curr_proof = %MerkleTree.Proof{
            hash_function: &MerkleTree.Crypto.sha256/1,
            hashes: split_proof(proof),
        }

        MerkleTree.Proof.proven?({block, index}, root, curr_proof)
    end

    @doc """
    Split whole string proof into array of elements size 64.

    Terminal case, return empty list
    """
    def split_proof("") do
        []
    end

    @doc """
    Split whole string proof into array of elements size 64.

    Main recursive logic for splitting proof string into a list.
    """
    def split_proof(proof) do
        Validator.validate_proof(proof)

        [String.slice(proof, 0, 64) | split_proof(String.slice(proof, 64, String.length(proof) - 64))]
    end

    @doc """
    Starts a new string for root hash.
    """
    def start_link(_opts) do
      Agent.start_link(fn -> "" end)
    end
  
    @doc """
    Sets the merkle root.
    """
    def set(merkle, root) do
      Validator.validate_root(root)
      Agent.update(merkle, fn _ -> root end)
    end
  
    @doc """
    Gets the merkle root.
    """
    def get(merkle) do
      Agent.get(merkle, &fn x -> x end.(&1))
    end
  end
  