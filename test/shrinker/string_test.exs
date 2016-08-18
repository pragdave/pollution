defmodule Shrinker.StringTest do

  use ExUnit.Case
  alias Pollution.Shrinker, as: S
  alias Pollution.VG, as: VG

  describe "list shrinking" do

    def do_shrink(code, current, args) do
      with name   = :wibble,
           state  = %{ name => VG.string(args) },
           locals = %{ name => current },
      do: S.shrink_until_done(name, { code, state, locals })
    end

    test "stops on empty string" do
      assert_passes = fn (_) ->
        false
      end
    
      assert do_shrink(assert_passes, "", min: 0, max: 0) == ""
    end

    test "stops on string of fixed length" do
      assert_passes = fn (_) ->
        false
      end
    
      assert do_shrink(assert_passes, "cat", min: 3, max: 3) == "cat"
    end

    test "reduces the length of a string to zero if appropriate" do
      assert_passes = fn (_) ->
        false
      end
      assert do_shrink(assert_passes, "wibble", min: 0) == ""
    end

    test "reduces the length until a test passes" do
      assert_passes = fn (%{wibble: val}) ->
        String.length(val) <= 2
      end
      assert do_shrink(assert_passes, "wibble", min: 0) == "le"
    end

    test "converts a string to lowercase ascii if it contains utf" do
      assert_passes = fn (%{wibble: val}) ->
        String.length(val) <= 2
      end
      with result = do_shrink(assert_passes, "å∫ç", min: 0) do
        assert String.length(result) == 2
        result
        |> String.to_charlist
        |> Enum.each(fn ch -> assert ch in ?a..?z end)
      end

    end

  end
end
