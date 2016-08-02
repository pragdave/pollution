defmodule Generator.ListTest do

  use ExUnit.Case

  alias Pollution.Generator, as: G
  import Pollution.VG
  
  describe "creation" do
    test "with no arguments" do
      with l = list() do
        assert [] in l.must_have
        assert is_integer(l.min)
        assert is_integer(l.max)
        assert l.min <= l.max
      end
    end
  
    test "with 1 argument" do
      with l = list(3) do
        assert l.min == 3
        assert l.max == 3
        assert !([] in l.must_have)
      end
    end
  
    test "with 2 arguments" do
      with l = list(3,5) do
        assert (![] in l.must_have)
        assert l.min == 3
        assert l.max == 5
      end
    end
    
    test "with 2 arguments and a minimum of 0" do
      with l = list(0,5) do
        assert [] in l.must_have
        assert l.min == 0
        assert l.max == 5
      end
    end
    
    test "with a type argument" do
      with l = list(int) do
        assert [] in l.must_have
      end
    end
  end


  describe "a generated list" do
    test "has a fixed length if so specified" do
      list(4)
      |> G.as_stream([])
      |> Enum.take(5)
      |> Enum.each(fn a_list ->
          assert length(a_list) == 4
        end)
    end
    
    test "has a length between min and max" do
      min = 2
      max = 10
      list(min, max)
      |> G.as_stream([])
      |> Enum.take(100)
      |> Enum.each(fn a_list ->
        assert length(a_list) >= min
        assert length(a_list) <= max
      end)
    end
    
    test "has elements of the correct type (int)" do
      list(int)
      |> G.as_stream([])
      |> Enum.take(5)
      |> Enum.each(fn a_list ->
        Enum.each(a_list, fn (i) -> assert is_integer(i) end)
      end)
    end
  
    test "has elements of the correct type (value)" do
      list(value("cat"))
      |> G.as_stream([])
      |> Enum.take(5)
      |> Enum.each(fn a_list ->
        Enum.each(a_list, fn (i) -> assert i == "cat" end)
      end)
    end
  
    test "has elements of the correct type with constraints" do
      list(int(min: 2, max: 4))
      |> G.as_stream([])
      |> Enum.take(5)
      |> Enum.each(fn a_list ->
        Enum.each(a_list, fn (i) ->
          assert is_integer(i)
          assert i in 2..4
        end)
      end)
    end
  end
end
