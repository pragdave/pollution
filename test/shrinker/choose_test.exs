defmodule Shrinker.ChooseTest do

  use   ExUnit.Case
  alias Pollution.Generator, as: G
  alias Pollution.Shrinker,  as: S
  alias Pollution.VG,        as: VG

  describe "choose() shrinking" do

    def do_shrink(code, current, state) do
      with name   = :wibble,
           state  = %{ name => state },
           locals = %{ name => current },
      do: S.shrink_until_done(name, { code, state, locals })
    end

    test "shrinks the type if int given" do
      assert_passes = fn (_) -> false end
      state         = VG.choose(from: [VG.int(must_have: [99])])
    
      { value, new_state } = G.next_value(state)
    
      assert value == 99
      assert do_shrink(assert_passes, 99, new_state) == 0
    end

    test "shrinks the correct type if multiple types given" do
      assert_passes = fn (_) -> false end

      state =  VG.choose(from: [VG.int, VG.atom, VG.string])

      Enum.each 1..50, fn (_) ->
        { value, state } = G.next_value(state)

        target = cond do
          is_integer(value) -> 0
          is_atom(value)    -> :""
          is_binary(value)  -> ""
        end

        assert do_shrink(assert_passes, value, state.last_child) == target
      end
    end

  end
end
