defmodule ValueTest do

  use ExUnit.Case

  alias Pollution.Generator, as: G
  import Pollution.VG

  test "an integer is returned if an integer is given" do
    result = value(29) |> G.as_stream |> Enum.take(5)
    assert result == [29, 29, 29, 29, 29 ]
  end


  test "a list is returned if a list is given" do
    result = value([1,2]) |> G.as_stream |> Enum.take(3)
    assert result == [ [1,2], [1,2], [1,2] ]
  end
end

