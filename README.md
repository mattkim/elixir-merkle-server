# MerkleWordServer

Validates messages sent as merkle proofs.

## Install Deps

Install deps to get merkle tree lib:

```
mix deps.get
```

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
iex> alias MerkleWordServer.Registry, as: Registry
MerkleWordServer.Registry
iex> alias MerkleWordServer.Merkle, as: Merkle
MerkleWordServer.Merkle
iex> mt = Merkle.create_merkle(["a", "b", "c", "d"])
%MerkleTree{
  blocks: ["a", "b", "c", "d"],
  hash_function: &MerkleTree.Crypto.sha256/1,
  root: %MerkleTree.Node{
    children: [
      %MerkleTree.Node{
        children: [
          %MerkleTree.Node{
            children: [],
            height: 0,
            value: "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb"
          },
          %MerkleTree.Node{
            children: [],
            height: 0,
            value: "3e23e8160039594a33894f6564e1b1348bbd7a0088d42c4acb73eeaed59c009d"
          }
        ],
        height: 1,
        value: "62af5c3cb8da3e4f25061e829ebeea5c7513c54949115b1acc225930a90154da"
      },
      %MerkleTree.Node{
        children: [
          %MerkleTree.Node{
            children: [],
            height: 0,
            value: "2e7d2c03a9507ae265ecf5b5356885a53393a2029d241394997265a1a25aefc6"
          },
          %MerkleTree.Node{
            children: [],
            height: 0,
            value: "18ac3e7343f016890c510e93f935261169d9e3f565436429830faf0934f4f8e4"
          }
        ],
        height: 1,
        value: "d3a0f1c792ccf7f1708d5422696263e35755a86917ea76ef9242bd4a8cf4891a"
      }
    ],
    height: 2,
    value: "58c89d709329eb37285837b042ab6ff72c7c8f74de0446b091b6a0131c102cfd"
  }
}
iex> proof = Merkle.create_proof(mt, 1)
{"b", 1,
 "d3a0f1c792ccf7f1708d5422696263e35755a86917ea76ef9242bd4a8cf4891aca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb"}
iex> Registry.reset(Registry, mt.root().value)
{:ok, "58c89d709329eb37285837b042ab6ff72c7c8f74de0446b091b6a0131c102cfd"}
iex> Registry.push(Registry, elem(proof, 0), elem(proof, 1), elem(proof, 2))
{:ok, true}
iex> Registry.get_blocks(Registry)
{:ok, [nil, "b"]}
```
