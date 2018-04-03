defmodule MerkleWordServer.BlocksTest do
  use ExUnit.Case, async: false

  alias MerkleWordServer.Blocks, as: Blocks

  setup do
    {:ok, blocks} = Blocks.start_link([])
    %{blocks: blocks}
  end

  test "stores values by key", %{blocks: blocks} do
    assert Blocks.get(blocks, 0) == nil

    Blocks.put(blocks, 0, "a")
    Blocks.put(blocks, 2, "c")
    assert Blocks.get(blocks, 0) == "a"
    assert Blocks.get(blocks, 2) == "c"
    assert Blocks.get(blocks, 1) == nil
  end

  test "get map as list", %{blocks: blocks} do
    Blocks.put(blocks, 0, "a")
    Blocks.put(blocks, 2, "c")
    Blocks.put(blocks, 1, "b")
    
    m = Blocks.get(blocks)
    assert m == %{0 => "a", 1 => "b", 2 => "c"}

    l = Blocks.to_list(m)
    assert l == [{0, "a"}, {1, "b"}, {2, "c"}]
  end

  test "expand test", %{blocks: blocks} do
    Blocks.put(blocks, 0, "a")
    Blocks.put(blocks, 2, "c")
    Blocks.put(blocks, 1, "b")
    Blocks.put(blocks, 6, "g")
    
    m = Blocks.get(blocks)
    l = Blocks.to_list(m)
    e = Blocks.expand(l)

    assert e == ["a", "b", "c", nil, nil, nil, "g"]
  end

  test "expand nil first test", %{blocks: blocks} do
    Blocks.put(blocks, 6, "g")

    m = Blocks.get(blocks)
    l = Blocks.to_list(m)
    e = Blocks.expand(l)

    assert e == [nil, nil, nil, nil, nil, nil, "g"]
  end

  test "expand empty test" do
    assert Blocks.expand([]) == []
  end

  test "expand one element test" do
    assert Blocks.expand([{0, "a"}]) == ["a"]
  end

  test "expand negative index test" do
    assert_raise RuntimeError, fn ->
      Blocks.expand([{-2, "a"}])
    end
  end
end
