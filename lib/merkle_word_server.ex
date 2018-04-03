defmodule MerkleWordServer do
  use Application

  alias MerkleWordServer.Supervisor, as: Supervisor

  @moduledoc """
  Documentation for MerkleWordServer.
  """

  def start(_type, _args) do
    Supervisor.start_link(name: Supervisor)
  end
end
