defmodule MerkleWordServer.Blocks do
  use Agent

  @doc """
  Convert map of blocks to a list of sorted tuples.
  """
  def to_list(blocks) do
    List.keysort(Map.to_list(blocks), 0)
  end

  @doc """
  Expand list of sorted map list where nil is in place of missing indexes.

  Handles edge case for empty arrays
  """
  def expand([]) do
    []
  end

  @doc """
  Expand list of sorted map list where nil is in place of missing indexes.

  Handles initial call with default i, and prev_idx.
  """
  def expand(a) do
    expand(a, 0, -1)
  end

  @doc """
  Expand list of sorted map list where nil is in place of missing indexes.

  Handles terminal case when we reach the end of the list.
  """
  def expand(a, i, _) when i >= length(a) do
    []
  end

  @doc """
  Expand list of sorted map list where nil is in place of missing indexes.

  Main recursive expression for expanding map list.
  """
  def expand(a, i, prev_idx) do
    curr_idx = index(a, i)
    diff_idx = curr_idx - prev_idx
    curr_val = val(a, i)

    cond do
        diff_idx > 1 ->
            dupe(nil, diff_idx - 1) ++ [curr_val] ++ expand(a, i + 1, curr_idx)
        true ->
            [curr_val | expand(a, i + 1, curr_idx)]
    end
  end

  @doc """
  Duplicate value by i times.
  """
  def dupe(val, i) do
    List.duplicate(val, i)
  end 

  @doc """
  Get the index in the tuple.
  """
  def index(a, i) do
    elem(Enum.at(a, i), 0)
  end

  @doc """
  Get the value in the tuple.
  """
  def val(a, i) do
    elem(Enum.at(a, i), 1)
  end

  @doc """
  Starts a new list of blocks.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the `blocks` by `key`.
  """
  def get(blocks, key) do
    Agent.get(blocks, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `blocks`.
  """
  def put(blocks, key, value) do
    Agent.update(blocks, &Map.put(&1, key, value))
  end

  @doc """
  Gets the entire map.
  """
  def get(blocks) do
    Agent.get(blocks, &fn x -> x end.(&1))
  end
end
