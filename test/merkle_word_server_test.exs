defmodule MerkleWordServerTest do
  use ExUnit.Case
  doctest MerkleWordServer

  test "greets the world" do
    assert MerkleWordServer.hello() == :world
  end
end
