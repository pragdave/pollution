defmodule Generator.MapTest do

  use ExUnit.Case

  import Pollution.VG, only: [ atom: 0, int: 0, string: 1, map: 1, value: 1 ]
  alias  Pollution.Generator, as: G

  def run_test(options, test_code) do
    map(options)
    |> G.as_stream
    |> Enum.take(1)
    |> Enum.each(test_code)
  end

  test "map() returns maps" do
    run_test([], fn map ->
      assert is_map(map)
    end)
  end
  
  test "map returns a range of sizes" do
    run_test([min: 3, max: 6], fn map ->
      assert map_size(map) in 3..6
    end)
  end

  test "map honors like:" do
    run_test([like: %{ int => string(chars: :lower), atom => value(42) }], fn map ->

      contents = map |> Map.to_list |> Enum.sort
  
      assert [ { k1, v1 }, { k2, v2 } ]  = contents
  
      assert is_integer(k1)
      assert is_binary(v1)
      assert (v1 |> String.to_char_list |> Enum.all?(fn ch -> ch in ?a..?z end))
  
    assert is_atom(k2)
    assert v2 == 42
    end)
  end

  test "map honors of:" do
    run_test([like: %{ int => string(chars: :lower), atom => value(42) }], fn map ->

      map
      |> Map.to_list
      |> Enum.each(
                   fn
                     {k, v} when is_integer(k) ->
                       assert is_binary(v)
                     {k, v} ->
                       assert is_atom(k)
                       assert v == 42
                   end)
    end)
  end
end
