defmodule MerkleWordServer.RegistryTest do
    use ExUnit.Case, async: false

    alias MerkleWordServer.Registry, as: Registry

    setup do
      registry = start_supervised!(Registry)
      %{registry: registry}
    end
  
    test "Test validating proof.", %{registry: registry} do
        mt = Registry.create_merkle(["a", "b", "c", "d"])
        proof = Registry.create_proof(mt, 1)
        
        # TODO: might be a race condition here actually.
        result = Registry.reset(registry, mt.root().value)

        assert result == {:ok, "58c89d709329eb37285837b042ab6ff72c7c8f74de0446b091b6a0131c102cfd"}

        result = Registry.get_blocks(registry)

        assert result == {:ok, []}

        result = Registry.push(registry, elem(proof, 0), elem(proof, 1), elem(proof, 2))

        assert result == {:ok, true}

        result = Registry.get_blocks(registry)

        assert result == {:ok, [nil, "b"]}
    end

    test "Test validating many proofs.", %{registry: registry} do
        mt = Registry.create_merkle(["a", "b", "c", "d"])
        Registry.reset(registry, mt.root().value)

        proof = Registry.create_proof(mt, 0)
        Registry.push(registry, elem(proof, 0), elem(proof, 1), elem(proof, 2))
        assert Registry.get_blocks(registry) == {:ok, ["a"]}

        proof = Registry.create_proof(mt, 3)
        Registry.push(registry, elem(proof, 0), elem(proof, 1), elem(proof, 2))
        assert Registry.get_blocks(registry) == {:ok, ["a", nil, nil, "d"]}

        proof = Registry.create_proof(mt, 2)
        Registry.push(registry, elem(proof, 0), elem(proof, 1), elem(proof, 2))
        assert Registry.get_blocks(registry)  == {:ok, ["a", nil, "c", "d"]}

        proof = Registry.create_proof(mt, 1)
        Registry.push(registry, elem(proof, 0), elem(proof, 1), elem(proof, 2))
        assert Registry.get_blocks(registry)  == {:ok, ["a", "b", "c", "d"]}
    end

    # TODO: test bad blocks, test bad proofs, test array index out of bounds.
  end