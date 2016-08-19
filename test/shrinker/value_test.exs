defmodule Shrinker.ValueTest do

  use   ExUnit.Case
  alias Pollution.Shrinker, as: S
  alias Pollution.VG, as: VG

  describe "value shrinking" do

    def do_shrink(code, current, args) do
      with name   = :wibble,
           state  = %{ name => VG.value(args) },
           locals = %{ name => current },
      do: S.shrink_until_done(name, { code, state, locals })
    end

    test "returns the value" do
      assert_passes = fn (_) -> false end
    
      assert do_shrink(assert_passes, 123, 123) == 123
    end
  end
end
