defmodule ChooseTest do

  use ExUnit.Case

  alias Pollution.Generator, as: G
  import Pollution.VG

  test "a choice of one item is just that item" do
    result = choose(from: value(42)) |> G.as_stream |> Enum.take(5)
    assert result == [ 42, 42, 42, 42, 42 ]
  end

  test "a choice from a list returns various items from that list" do
    result = choose(from: [ value(1), value(2), value(3) ]) |> G.as_stream |> Enum.take(100)

    counts = Enum.reduce(result, %{}, fn v, counts ->
      Map.update(counts, v, 0, &(&1+1))
    end)

    with likely_range = 10..50 do
      assert counts[1] in likely_range
      assert counts[2] in likely_range
      assert counts[3] in likely_range
    end
  end

end

