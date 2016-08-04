defmodule Generator.AtomTest do

  use ExUnit.Case

  alias  Pollution.Generator, as: G
  import Pollution.VG, only: [ atom: 1 ]

  def run_test(options, test_code) do
    atom(options)
    |> G.as_stream
    |> Enum.take(100)
    |> Enum.each(test_code)
  end

  test "atom() returns atoms" do
    run_test([], fn a->
      assert is_atom(a)
    end)
  end

  test "length constraints work" do
    run_test([min: 4, max: 8], fn a ->
      with len = a |> Atom.to_string |> String.length,
      do: assert len in 4..8
    end)
  end
  
  test "setting must_have adds items to the stream" do
    atoms = atom(must_have: [ :donald, :mickey ]) |> G.as_stream([]) |> Enum.take(100)
    assert :donald in atoms
    assert :mickey in atoms
  end

end
