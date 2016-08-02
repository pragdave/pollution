defmodule ValueTest do

  use ExUnit.Case

  alias  Pollution.
  import Pollution.Generator

  test "an integer is returned if an integer is given" do
    result = a(29) |> as_stream |> Enum.take(5)
    assert result == [29, 29, 29, 29, 29 ]
  end
end

