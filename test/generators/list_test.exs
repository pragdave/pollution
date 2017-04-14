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
      with l = list(int()) do
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
      list(int())
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

  describe "derived values" do
    test "are looked up initially" do
      list(derived: [ min: fn locals -> locals[:a] end], max: 12)
      |> G.as_stream([a: 10])
      |> Enum.take(100)
      |> Enum.each(fn v -> assert length(v) >= 10 && length(v) <= 12 end)
    end

    test "translate child types appropriately" do
      list(derived: [ of: fn locals ->
        float(min: locals[:a], max: locals[:b])
      end], max: 10)
      |> G.as_stream([a: 0, b: 5])
      |> Enum.take(100)
      |> Enum.each(fn vs ->
        assert Enum.all?(vs, fn v -> v >= 0.0 and v <= 5.0 end)
      end)
    end

    test "prune must have list" do
      list(derived: [ of: fn locals -> locals[:a] end], max: 12, must_have: [ [8, 9, 10, 100] ])
      |> G.as_stream([a: int(max: 20)])
      |> Enum.take(100)
      |> Enum.each(fn v ->
        assert Enum.all?(v, &is_integer/1) and
        Enum.all?(v, &(&1 <= 20)) and
        length(v) <= 12 end)
    end

    test "recalculate each time" do
      f = list(derived: [ min: fn locals -> locals[:a] end], max: 12)
      { v, f1 } = G.next_value(f, [ a: 10 ])

      assert length(v) >= 10 && length(v) <= 12
      assert f1.min == 10.0

      { v, f2 } = G.next_value(f1, [ a: 12 ])

      assert length(v) == 12
      assert f2.min == 12.0
    end
  end
end
