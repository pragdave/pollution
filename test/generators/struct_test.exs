defmodule Generator.StructTest.MyStruct do
  defstruct an_atom: :a, an_int: 0, other: nil
end

defmodule Generator.StructTest do

  alias Generator.StructTest.MyStruct

  use ExUnit.Case

  alias Pollution.VG

  alias  Pollution.Generator, as: G

  def run_test(struct_module, count \\ 50, test_code) do
    VG.struct(struct_module)
    |> G.as_stream
    |> Enum.take(count)
    |> Enum.each(test_code)
  end

  test "struct() accepts the name of a struct" do
    run_test(MyStruct, 1, fn str ->
      assert %MyStruct{} = str
    end)
  end
  
  test "struct() accepts the instance of a struct" do
    run_test(%MyStruct{}, 1, fn str ->
      assert %MyStruct{} = str
    end)
  end
  
  test "the generator types are based on the defaults" do
    run_test(%MyStruct{}, fn str ->
      assert %MyStruct{an_atom: a, an_int: i} = str
      assert is_atom(a)
      assert is_integer(i)
    end)
  end

  test "the generator types can be overridden" do
    run_test(%MyStruct{other: VG.float}, fn str ->
      assert %MyStruct{an_atom: a, an_int: i, other: f} = str
      assert is_atom(a)
      assert is_integer(i)
      assert is_float(f)
    end)
  end
  
end
