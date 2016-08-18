defmodule Shrinker.IntTest do

  use ExUnit.Case
  alias Pollution.Shrinker, as: S
  alias Pollution.VG, as: VG

  describe "integer shrinking" do

    def do_shrink(min, max, current, code) do
      with name   = :wibble,
           state  = %{ name => VG.int(min: min, max: max) },
           locals = %{ name => current },
      do: S.shrink_until_done(name, { code, state, locals })
    end

    test "stops when min = max" do
      assert_passes = fn (_) ->
        flunk "shouldn't call the code"
      end
    
      assert do_shrink(2, 2, 2, assert_passes) == 2
    end
    
    test "finds value when max = min+1 and min is the value" do
      max = 4
      min = 3
    
      assert_passes = fn (%{wibble: val}) ->
        val != min
      end
      assert do_shrink(min, max, min, assert_passes) == min
    end
    
    test "finds value when max = min+1 and max is the value" do
      max = 4
      min = 3
    
      assert_passes = fn (%{wibble: val}) ->
        val != max
      end
    
      assert do_shrink(min, max, max, assert_passes) == max
    end
    
    test "finds value in larger range" do
      max = 40
      min = 3
    
      assert_passes = fn (%{wibble: val}) ->
        val < 27
      end
    
      assert do_shrink(min, max, max-5, assert_passes) == 27
    end
    

    test "finds value when current is negative" do
      max = 40
      min = -10
    
      assert_passes = fn (%{wibble: val}) ->
        val < -5
      end
    
      assert do_shrink(min, max, 5, assert_passes) == 0
    end

  end
end
