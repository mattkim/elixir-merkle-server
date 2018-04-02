defmodule MerkleWordServerTest do
  use ExUnit.Case, async: false
  doctest MerkleWordServer

  test "greets the world" do
    assert MerkleWordServer.hello() == :world
  end

  test "handle reset" do
    assert MerkleWordServer.handle_call({:reset, "123"}) == {:reset, "123"}
  end

  test "handle push" do
    assert MerkleWordServer.handle_call({:push, "c", "2", "123"}) == {:push, "c", "2", "123"}
  end

  test "handle get_blocks" do
    assert MerkleWordServer.handle_call({:get_blocks}) == {:get_blocks}
  end

  test "handle wrong args" do
    assert MerkleWordServer.handle_call({:get_blocks, "123"}) == {:error, "Handle call not recognized!"}
  end

  test "handle wrong method" do
    assert MerkleWordServer.handle_call({:oops}) == {:error, "Handle call not recognized!"}
  end
end
