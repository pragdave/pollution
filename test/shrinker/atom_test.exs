defmodule Shrinker.AtomTest do

  use   ExUnit.Case
  alias Pollution.Shrinker, as: S
  alias Pollution.VG, as: VG

  describe "atom shrinking" do

    def do_shrink(code, current, args) do
      with name   = :wibble,
           state  = %{ name => VG.atom(args) },
           locals = %{ name => current },
      do: S.shrink_until_done(name, { code, state, locals })
    end

    test "stops on empty atom" do
      assert_passes = fn (_) ->
        flunk "shouldn't call the code"
      end
    
      assert do_shrink(assert_passes, :"", min: 0, max: 0) == :""
    end

    test "stops on atom of fixed length" do
      assert_passes = fn (_) ->
        flunk "shouldn't call the code"
      end
    
      assert do_shrink(assert_passes, :abc, min: 3, max: 3) == :abc
    end
    
    test "reduces the length of an atom to zero if appropriate" do
      assert_passes = fn (_) ->
        false
      end
      assert do_shrink(assert_passes, :abcde, min: 0) == :""
    end

    test "reduces the length until a test passes" do
      assert_passes = fn (%{wibble: val}) ->
        (val |> Atom.to_charlist |> length) <= 2
      end
      assert do_shrink(assert_passes, :abcde, min: 0) == :de
    end

  end
end
