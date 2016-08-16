defmodule Shrinker.IntTest do

  use ExUnit.Case
  alias Pollution.Generator.Int

  describe "binary chop" do

    def env(code, state \\ %{}, locals \\ %{ name: 0 }) do
      { code, state, locals }
    end

    test "stops when min = max" do
      dummy_code = fn (_) ->
        flunk "shouldn't call the code"
      end
    
      sp = Int.shrink_params(%{min: 2, max: 2}, 2)
      assert Int.shrink_by_scanning(:name, env(dummy_code), sp) == 2
    end
    
    test "finds value when max = min+1 and min is the value" do
      max = 4
      min = 3
      sp = Int.shrink_params(%{min: min, max: max}, min)
    
      dummy_code = fn (%{name: val}) ->
        val != min
      end
      assert Int.shrink_by_scanning(:name, env(dummy_code), sp) == min
    end
    
    test "finds value when max = min+1 and max is the value" do
      max = 4
      min = 3
      sp = Int.shrink_params(%{min: min, max: max}, max)
    
      dummy_code = fn (%{name: val}) ->
        val != max
      end
    
      assert Int.shrink_by_scanning(:name, env(dummy_code), sp) == max
    end

    test "finds value in larger range" do
      max = 40
      min = 3
      sp = Int.shrink_params(%{min: min, max: max}, max - 5)

      dummy_code = fn (%{name: val}) ->
        val < 27
      end
    
      assert Int.shrink_by_scanning(:name, env(dummy_code), sp) == 27
    end


    test "finds value when current is negative" do
      max = 40
      min = -10
      sp = Int.shrink_params(%{min: min, max: max}, 5)

      dummy_code = fn (%{name: val}) ->
        val < 5
      end
    
      assert Int.shrink_by_scanning(:name, env(dummy_code), sp) == 5
    end


  end
end
