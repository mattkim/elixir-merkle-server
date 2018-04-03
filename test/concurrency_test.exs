defmodule MerkleWordServer.ConcurrencyTest do
    use ExUnit.Case, async: false

    alias MerkleWordServer.Merkle, as: Merkle
    alias MerkleWordServer.Registry, as: Registry

    setup do
      registry = start_supervised!(Registry)
      %{registry: registry}
    end
  
    test "Test concurrency.", %{registry: registry} do
        mt = Merkle.create_merkle(["a", "b", "c", "d"])
        proof = Merkle.create_proof(mt, 0)

        parent = self()

        tasks = spawn_many_resets(parent, registry, mt.root().value, 100) ++
            spawn_many_pushes(parent, registry, elem(proof, 0), elem(proof, 1), elem(proof, 2), 100)
        Enum.each(tasks, fn task -> Task.await(task) end)
    end

    test "Test concurrency pushes", %{registry: registry} do
        mt = Merkle.create_merkle(["a", "b", "c", "d"])

        Registry.reset(registry, mt.root().value)

        proof0 = Merkle.create_proof(mt, 0)
        proof1 = Merkle.create_proof(mt, 1)
        proof2 = Merkle.create_proof(mt, 2)

        parent = self()

        tasks = spawn_many_pushes(parent, registry, elem(proof0, 0), elem(proof0, 1), elem(proof0, 2), 100) ++
            spawn_many_pushes(parent, registry, elem(proof1, 0), elem(proof1, 1), elem(proof1, 2), 100) ++
            spawn_many_pushes(parent, registry, elem(proof2, 0), elem(proof2, 1), elem(proof2, 2), 100)
        Enum.each(tasks, fn task -> Task.await(task) end)

        result = Registry.get_blocks(registry)
        assert result == {:ok, ["a", "b", "c"]}
    end

    def spawn_many_resets(_, _, _, num) when num <= 0 do
        []
    end

    def spawn_many_resets(parent, registry, root, num) do
        [   
            Task.async(
                fn ->
                    assert Registry.reset(registry, root) == {:ok, "58c89d709329eb37285837b042ab6ff72c7c8f74de0446b091b6a0131c102cfd"}
                end
            ) | spawn_many_resets(parent, registry, root, num - 1)
        ]
    end

    def spawn_many_pushes(_, _, _, _, _, num) when num <= 0 do
        []
    end

    def spawn_many_pushes(parent, registry, block, index, proof, num) do
        [   
            Task.async(
                fn ->
                    assert Registry.push(registry, block, index, proof) == {:ok, true}
                end
            ) | spawn_many_pushes(parent, registry, block, index, proof, num - 1)
        ]
    end
  end
