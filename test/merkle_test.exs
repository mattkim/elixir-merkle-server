defmodule MerkleWordServer.MerkleTest do
    use ExUnit.Case, async: false
  
    alias MerkleWordServer.Merkle, as: Merkle
  
    setup do
      {:ok, merkle} = Merkle.start_link([])
      %{merkle: merkle}
    end
  
    test "set merkle root", %{merkle: merkle} do
      Merkle.set(merkle, "58c89d709329eb37285837b042ab6ff72c7c8f74de0446b091b6a0131c102cfd")
      assert Merkle.get(merkle) == "58c89d709329eb37285837b042ab6ff72c7c8f74de0446b091b6a0131c102cfd"
      Merkle.set(merkle, "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb")
      assert Merkle.get(merkle) == "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb"
    end

    test "test hashes" do
        h = Merkle.split_proof("d3a0f1c792ccf7f1708d5422696263e35755a86917ea76ef9242bd4a8cf4891aca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bbd3a0f1c792ccf7f1708d5422696263e35755a86917ea76ef9242bd4a8cf4891aca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bbd3a0f1c792ccf7f1708d5422696263e35755a86917ea76ef9242bd4a8cf4891aca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bbd3a0f1c792ccf7f1708d5422696263e35755a86917ea76ef9242bd4a8cf4891aca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb")
        assert h == ["d3a0f1c792ccf7f1708d5422696263e35755a86917ea76ef9242bd4a8cf4891a",
        "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb",
        "d3a0f1c792ccf7f1708d5422696263e35755a86917ea76ef9242bd4a8cf4891a",
        "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb",
        "d3a0f1c792ccf7f1708d5422696263e35755a86917ea76ef9242bd4a8cf4891a",
        "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb",
        "d3a0f1c792ccf7f1708d5422696263e35755a86917ea76ef9242bd4a8cf4891a",
        "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb"]
    end

    test "test mod 64" do
      assert_raise RuntimeError, fn ->
        Merkle.split_proof("d3a0")
      end
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
  end
  