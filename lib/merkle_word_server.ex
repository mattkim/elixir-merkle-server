defmodule MerkleWordServer do
  @moduledoc """
  Documentation for MerkleWordServer.
  """

  # TODO: Hook up to app / server
  def handle_call(s) do
    case s do
      {:reset, _} -> s
      {:push, _, _, _} -> s
      {:get_blocks} -> s
      _ -> {:error, "Handle call not recognized!"}
    end
  end
end
