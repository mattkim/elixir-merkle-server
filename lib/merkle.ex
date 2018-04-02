defmodule MerkleWordServer.Merkle do
    use Agent

    @doc """
    Validate proof matches with merkle root.
    """
    def proven?(block, index, root, proof) do
        splits = split_proof(proof)

        # TODO: also prove that the hash of the block
        # is equal to the first element in the proof
        # hash(block) == splits[0]

        curr_proof = %MerkleTree.Proof{
            hash_function: &MerkleTree.Crypto.sha256/1,
            hashes: splits,
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
        #TODO: check if len is < 64
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
    def set(merkle, value) do
      Agent.update(merkle, fn _ -> value end)
    end
  
    @doc """
    Gets the merkle root.
    """
    def get(merkle) do
      Agent.get(merkle, &fn x -> x end.(&1))
    end
  end
  