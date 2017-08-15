defmodule Shrinker.ListTest do

  use ExUnit.Case
  alias Pollution.Shrinker, as: S
  alias Pollution.VG, as: VG

  describe "list shrinking" do

    def do_shrink(code, current, args) do
      with name   = :wibble,
           state  = %{ name => VG.list(args) },
           locals = %{ name => current },
      do: S.shrink_until_done(name, { code, state, locals })
    end

    test "stops on empty list" do
      assert_passes = fn (_) ->
        flunk "shouldn't call the code"
      end

      assert do_shrink(assert_passes, [], min: 0, max: 0) == []
    end

    test "stops on list of fixed length" do
      assert_passes = fn (_) ->
        flunk "shouldn't call the code"
      end

      assert do_shrink(assert_passes, [1,2,3], min: 3, max: 3) == [1,2,3]
    end

    test "reduces the length of a list to zero if appropriate" do
      assert_passes = fn (_) ->
        false
      end
      assert do_shrink(assert_passes, [1,2,3,4], min: 0) == []
    end

    test "reduces the length until a test passes" do
      assert_passes = fn (%{wibble: val}) ->
        length(val) <= 1
      end
      assert do_shrink(assert_passes, [1,2,3,4], min: 0) == [3,4]
    end

    test "stops immediately if the first shrink passes" do
      assert_passes = fn (_) ->
        true
      end
      assert do_shrink(assert_passes, [1,2,3,4], min: 0) == [1,2,3,4]
    end
  end
end
