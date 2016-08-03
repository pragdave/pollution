defmodule Generator.TupleTest do

  use ExUnit.Case

  import Pollution.VG, only: [ int: 0, string: 1, tuple: 1, value: 1 ]
  alias  Pollution.Generator, as: G

  def run_test(options, test_code) do
    tuple(options)
    |> G.as_stream
    |> Enum.take(100)
    |> Enum.each(test_code)
  end

  test "tuple() returns tuples" do
    run_test([], fn tup ->
      assert is_tuple(tup)
    end)
  end

  test "tuple returns a range of sizes" do
    run_test([min: 3, max: 6], fn tup ->
      assert tuple_size(tup) in 3..6
    end)
  end

  test "tuple of given types" do
    run_test([like: { int, string(chars: :lower), value(42) }], fn tup ->
      assert tuple_size(tup) == 3
      assert is_integer(elem(tup, 0))
      assert is_binary(elem(tup, 1))
      assert elem(tup, 2) == 42
    end)
  end

end
