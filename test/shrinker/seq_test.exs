defmodule Shrinker.SeqTest do

  use   ExUnit.Case
  alias Pollution.Generator, as: G
  alias Pollution.Shrinker, as: S
  alias Pollution.VG, as: VG

  describe "seq() shrinking" do

    def do_shrink(code, current, state) do
      with name   = :wibble,
           state  = %{ name => state },
           locals = %{ name => current },
      do: S.shrink_until_done(name, { code, state, locals })
    end

    test "shrinks the type if int given" do
      assert_passes = fn (_) -> false end
      state         = VG.seq(of: [VG.int(must_have: [99])])
    
      { value, new_state } = G.next_value(state)
    
      assert value == 99
      assert do_shrink(assert_passes, 99, new_state) == 0
    end

    test "shrinks the correct type if multiple types given" do
      assert_passes = fn (_) -> false end

      state =  VG.seq(of: [VG.int, VG.atom, VG.string])

      { _value, state } = G.next_value(state)
      assert do_shrink(assert_passes, 99, state.last_child) == 0

      { _value, state } = G.next_value(state)
      assert do_shrink(assert_passes, :abc, state.last_child) == :""

      { _value, state } = G.next_value(state)
      assert do_shrink(assert_passes, "abc", state.last_child) == ""

      { _value, state } = G.next_value(state)
      assert do_shrink(assert_passes, 99, state.last_child) == 0

    end

  end
end
