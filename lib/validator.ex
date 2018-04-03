defmodule MerkleWordServer.Validator do

    def validate_proof(proof) do
        cond do
            rem(String.length(proof), 64) != 0 ->
                raise "Proof must be a factor of 64"
            true ->
                true
        end
    end

    def validate_root(root) do
        cond do
            String.length(root) != 64 ->
                raise "Root must be length 64"
            true ->
                true
        end
    end

    def validate_index(index) do
        cond do
            index < 0 ->
                raise "Index must be >= 0"
            true ->
                true
        end
    end

    def validate_index(index, block_length) do
        cond do
            index < 0 ->
                raise "Index must be >= 0"
            index >= block_length ->
                raise "Index must be < block_length"
            true ->
                true
        end
    end
end
