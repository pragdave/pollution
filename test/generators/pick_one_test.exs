defmodule PickOneTest do

  use ExUnit.Case

  alias Pollution.Generator, as: G
  import Pollution.VG

  test "a choice of one item is just that item" do
    result = pick_one(from: value(42)) |> G.as_stream |> Enum.take(5)
    assert result == [ 42, 42, 42, 42, 42 ]
  end

  test "a choice of one item in a list is just that item" do
    result = pick_one(from: [ value(42) ]) |> G.as_stream |> Enum.take(5)
    assert result == [ 42, 42, 42, 42, 42 ]
  end

  test "a choice of three items returns one of them" do
    counts = Enum.reduce(1..100, %{ }, fn _, counts ->
      result = pick_one(from: [ value(1), value(2), value(3) ]) |> G.as_stream |> Enum.take(1)
      Map.update(counts, hd(result), 0, &(&1+1))
    end)

    with likely_range = 15..45 do
      assert counts[1] in likely_range
      assert counts[2] in likely_range
      assert counts[3] in likely_range
    end
  end

  test "once chosen, the same value is always returned" do
    [ h | l ] = pick_one(from: [value(1), value(2), value(3)]) |> G.as_stream |> Enum.take(20)
    assert Enum.all?(l, fn val -> val == h end)
  end

end

