defmodule Chain do
  @moduledoc """
  Documentation for Chain.
  """

  defp hash_link(hash_type, link) do
    {:ok, link_json} = Poison.encode(link)

    hash_type
    |> :crypto.hash(link_json)
    |> Base.encode16()
  end

  def create(hash_type, content) do
    [%{:hash_type => hash_type, :content => content}]
  end

  def append(chain, content) do
    [
      %{
        :content => content,
        :previous_hash => hash_link(List.last(chain)[:hash_type], List.first(chain))
      }
      | chain
    ]
  end

  def verify(chain) do
    verify(List.last(chain)[:hash_type], chain)
  end

  def verify(hash_type, [l1, l2]) do
    l1[:previous_hash] == hash_link(hash_type, l2)
  end

  def verify(hash_type, [l1 | [l2 | ls]]) do
    if l1[:previous_hash] == hash_link(hash_type, l2) do
      verify([l2 | ls])
    else
      false
    end
  end
end
