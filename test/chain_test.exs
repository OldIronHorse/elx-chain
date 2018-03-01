defmodule ChainTest do
  use ExUnit.Case
  doctest Chain

  setup _context do
    base_chain =
      Enum.reduce(
        for _n <- 0..100 do
          Enum.random(-100..100)
        end,
        Chain.create(:sha256, %{:balance => 1000}),
        fn delta, chain ->
          Chain.append(chain, %{
            :delta => delta,
            :balance => List.first(chain)[:content][:balance] + delta
          })
        end
      )

    {:ok,
     [
       valid_chain: base_chain,
       invalid_chain:
         Enum.reduce(
           for _n <- 0..50 do
             Enum.random(-100..100)
           end,
           [
             %{
               :previous_hash => "5342532454235",
               :content => %{
                 :balance => List.first(base_chain)[:content][:balance],
                 :delta => 0
               }
             }
             | base_chain
           ],
           fn delta, chain ->
             Chain.append(chain, %{
               :delta => delta,
               :balance => List.first(chain)[:content][:balance] + delta
             })
           end
         )
     ]}
  end

  test "creates root link" do
    assert [
             %{
               :hash_type => :sha256,
               :content => %{:var1 => "val1", :var2 => 2, :var3 => 3.0}
             }
           ] = Chain.create(:sha256, %{:var1 => "val1", :var2 => 2, :var3 => 3.0})
  end

  test "append first link" do
    c =
      Chain.append(Chain.create(:sha256, %{:balance => 1000}), %{:balance => 1100, :delta => 100})

    [h, root] = c
    assert %{:balance => 1100, :delta => 100} = h[:content]
    {:ok, root_json} = Poison.encode(root)
    assert h[:previous_hash] == Base.encode16(:crypto.hash(:sha256, root_json))
  end

  test "verify valid and consistent chain", context do
    assert Chain.verify(context[:valid_chain])
  end

  test "verify invalid but consistent chain", context do
    assert not Chain.verify(context[:invalid_chain])
  end
end
