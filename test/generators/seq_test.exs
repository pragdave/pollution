defmodule SeqTest do

  use ExUnit.Case

  alias Pollution.Generator, as: G
  import Pollution.VG

  test "a sequence of one item returns that item" do
    result = seq(of: value(42)) |> G.as_stream |> Enum.take(5)
    assert result == [ 42, 42, 42, 42, 42 ]
  end

  test "a sequence of three items returns them" do
    result = seq(of: [value(1), value(2), value(3)]) |> G.as_stream |> Enum.take(3)
    assert result == [ 1, 2, 3 ]
  end

  test "a sequence of three items cycles through them" do
    result = seq(of: [value(1), value(2), value(3)]) |> G.as_stream |> Enum.take(5)
    assert result == [ 1, 2, 3, 1, 2 ]
  end

  test "a sequence of generators returns differing values of the correct type" do

    { ints, strings } = seq(of: [int(min: 3, max: 5000), string(min: 2, max: 15)])
                        |> G.as_stream
                        |> Enum.take(6)
                        |> Enum.split_with(&is_integer/1)

    assert length(ints)    == 3
    assert length(strings) == 3

    assert Enum.all?(ints,    &is_integer/1)
    assert Enum.all?(strings, &String.valid?/1)

    Enum.each(ints,    fn val -> assert val in 3..5000 end)
    Enum.each(strings, fn val -> assert String.length(val) in 2..15 end)

    for [ a, b, c ] <- [ ints, strings ] do
      assert a != b
      assert a != c
      assert b != c
    end

  end
end

