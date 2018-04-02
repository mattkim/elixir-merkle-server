# MerkleWordServer

Validates messages sent as merkle proofs.

## Testing

To run tests do:

```
mix test
```

## Gen Server

To interact with gen server run the interactive shell:

```
iex -S mix
```

Run the following commands to interact with the gen server:

```
alias MerkleWordServer.Registry, as: Registry

{:ok, registry} = Registry.start_link([])

mt = Registry.create_merkle(["a", "b", "c", "d"])
proof = Registry.create_proof(mt, 1)

Registry.reset(registry, mt.root().value)
Registry.push(registry, elem(proof, 0), elem(proof, 1), elem(proof, 2))
Registry.get_blocks(registry)
```
