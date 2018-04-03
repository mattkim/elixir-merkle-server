defmodule MerkleWordServer.RegistryTest do
    use ExUnit.Case, async: false

    alias MerkleWordServer.Merkle, as: Merkle
    alias MerkleWordServer.Registry, as: Registry

    setup do
      registry = start_supervised!(Registry)
      %{registry: registry}
    end
  
    test "Test validating proof.", %{registry: registry} do
        mt = Merkle.create_merkle(["a", "b", "c", "d"])
        proof = Merkle.create_proof(mt, 1)
        
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
        mt = Merkle.create_merkle(["a", "b", "c", "d"])
        Registry.reset(registry, mt.root().value)

        proof = Merkle.create_proof(mt, 0)
        Registry.push(registry, elem(proof, 0), elem(proof, 1), elem(proof, 2))
        assert Registry.get_blocks(registry) == {:ok, ["a"]}

        proof = Merkle.create_proof(mt, 3)
        Registry.push(registry, elem(proof, 0), elem(proof, 1), elem(proof, 2))
        assert Registry.get_blocks(registry) == {:ok, ["a", nil, nil, "d"]}

        proof = Merkle.create_proof(mt, 2)
        Registry.push(registry, elem(proof, 0), elem(proof, 1), elem(proof, 2))
        assert Registry.get_blocks(registry)  == {:ok, ["a", nil, "c", "d"]}

        proof = Merkle.create_proof(mt, 1)
        Registry.push(registry, elem(proof, 0), elem(proof, 1), elem(proof, 2))
        assert Registry.get_blocks(registry)  == {:ok, ["a", "b", "c", "d"]}
    end

    test "Test index out of bounds" do
        mt = Merkle.create_merkle(["a", "b", "c", "d"])

        assert_raise RuntimeError, fn ->
            Merkle.create_proof(mt, -1)
        end

        assert_raise RuntimeError, fn ->
            Merkle.create_proof(mt, 5)
        end
    end

    test "Test bad blocks, index, and proof", %{registry: registry} do
        mt = Merkle.create_merkle(["a", "b", "c", "d"])
        Registry.reset(registry, mt.root().value)

        proof = {"a", 0, "d3a0f1c792ccf7f1708d5422696263e35755a86917ea76ef9242bd4a8cf4891a3e23e8160039594a33894f6564e1b1348bbd7a0088d42c4acb73eeaed59c009d"}
        result = Registry.push(registry, elem(proof, 0), elem(proof, 1), elem(proof, 2))
        assert result == {:ok, true}

        # Should be "a"
        proof = {"x", 0, "d3a0f1c792ccf7f1708d5422696263e35755a86917ea76ef9242bd4a8cf4891a3e23e8160039594a33894f6564e1b1348bbd7a0088d42c4acb73eeaed59c009d"}
        result = Registry.push(registry, elem(proof, 0), elem(proof, 1), elem(proof, 2))
        assert result == {:ok, false}

        # Should be 0
        proof = {"x", 1, "d3a0f1c792ccf7f1708d5422696263e35755a86917ea76ef9242bd4a8cf4891a3e23e8160039594a33894f6564e1b1348bbd7a0088d42c4acb73eeaed59c009d"}
        result = Registry.push(registry, elem(proof, 0), elem(proof, 1), elem(proof, 2))
        assert result == {:ok, false}

        # Should be correct proof
        proof = {"x", 0, "fffff1c792ccf7f1708d5422696263e35755a86917ea76ef9242bd4a8cf4891a3e23e8160039594a33894f6564e1b1348bbd7a0088d42c4acb73eeaed59c009d"}
        result = Registry.push(registry, elem(proof, 0), elem(proof, 1), elem(proof, 2))
        assert result == {:ok, false}
    end
  end