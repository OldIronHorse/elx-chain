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
    verify(chain, fn _l1, _l0 -> :true end)
  end
  def verify(chain, consistency_fn) do 
    do_verify(List.last(chain)[:hash_type], consistency_fn, chain)
  end

  defp do_verify(hash_type, consistency_fn, [l1, l2]) do
    l1[:previous_hash] == hash_link(hash_type, l2) and 
      consistency_fn.(l1[:content], l2[:content])
  end

  defp do_verify(hash_type, consistency_fn, [l1 | [l2 | ls]]) do
    if l1[:previous_hash] == hash_link(hash_type, l2) and
        consistency_fn.(l1[:content], l2[:content]) do
      do_verify(hash_type, consistency_fn, [l2 | ls])
    else
      false
    end
  end
end
