defmodule Shrinker.FloatTest do

  use   ExUnit.Case
  alias Pollution.Shrinker,        as: S
  alias Pollution.VG,              as: VG
  alias Pollution.Generator.Float, as: F



  describe "float shrinking" do

    def do_shrink(min, max, current, code) do
      with name   = :wibble,
           state  = %{ name => VG.float(min: min, max: max) },
           locals = %{ name => current },
      do: S.shrink_until_done(name, { code, state, locals })
    end

    def my_assert_in_delta(a, b) do
      assert_in_delta(a, b, F.delta_for(a, b))
    end

    test "stops if min =~= max" do
      assert_passes = fn (_) ->
        flunk "shouldn't call the code"
      end
    
      with result = do_shrink(2.0, 2.0 + F.epsilon, 2.0, assert_passes),
      do:  my_assert_in_delta(result, 2.0)
    end
    
    test "finds value in range" do
      max = 40.5
      min = 3.14159
  
      assert_passes = fn (%{wibble: val}) ->
        val < 15.6
      end

      with result = do_shrink(min, max, max-5, assert_passes),
      do: my_assert_in_delta(result, 15.6)
    end

  
    test "finds value when current is negative" do
      max = 40
      min = -10
  
      assert_passes = fn (%{wibble: val}) ->
        val < -5
      end
    
      with result = do_shrink(min, max, 5, assert_passes),
      do:  my_assert_in_delta(result, -5)
    end
  
  end
end
