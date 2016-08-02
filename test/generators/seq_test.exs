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
  
end

