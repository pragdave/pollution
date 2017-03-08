defmodule IntTest do

  use ExUnit.Case

  alias Pollution.Generator, as: G
  import Pollution.VG

  describe "creation" do
    test "with no arguments" do
      with i = int() do
        assert i.type == G.Int
        assert  0 in i.must_have
        assert -1 in i.must_have
        assert  1 in i.must_have

        assert is_integer(i.min)
        assert is_integer(i.max)

        assert i.min < i.max
      end
    end

    test "with keyword arguments" do
      with i = int(min: 3, max: 20) do
        assert i.max == 20
        assert i.min == 3
        assert i.must_have == []
      end
    end

    test "truncates must_have to range" do
      with i = int(min: 1, max: 20) do
        assert i.max == 20
        assert i.min == 1
        assert i.must_have == [ 1 ]
      end
    end

    test "with keyword arguments including type-level constraints" do
      with i = int(min: 3, max: 20, must_have: [4,5,6]) do
        assert i.max == 20
        assert i.min == 3
        assert i.must_have == [4, 5, 6]
      end
    end

  end

  describe "generation using" do
    test "int() returns an integer" do
      int()
      |> G.as_stream()
      |> Enum.take(50)
      |> Enum.all?(fn val -> assert(is_integer(val)) end)
    end

    test "positive_int" do
      positive_int()
      |> G.as_stream()
      |> Enum.take(50)
      |> Enum.all?(&(&1 > 0))
    end

    test "negative_int" do
      negative_int()
      |> G.as_stream()
      |> Enum.take(50)
      |> Enum.all?(&(&1 < 0))
    end

    test "nonnegative_int" do
      nonnegative_int()
      |> G.as_stream()
      |> Enum.take(50)
      |> Enum.all?(&(&1 >= 0))
    end

  end

  describe "values returned" do
    test "include must_have values" do
      i = int(must_have: [5, 7, 9])

      assert i |> G.as_stream([]) |> Enum.take(3) == [ 5, 7, 9 ]
    end
  end

  describe "Uniform distribution" do
    test "has a mean around the middle" do
      i = int(min: 20, max: 40)
      numbers = i |> G.as_stream([]) |> Enum.take(100)
      mean = Enum.sum(numbers) / length(numbers)
      assert abs(mean - 30) < 2
    end
  end

  describe "derived values" do
    test "are looked up initially" do
      int(derived: [ min: fn locals -> locals[:a] end], max: 12)
      |> G.as_stream([a: 10])
      |> Enum.take(100)
      |> Enum.each(fn v -> assert v in 10..12 end)
    end


    test "prune must have list" do
      int(derived: [ min: fn locals -> locals[:a] end], max: 12, must_have: [8, 9, 10, 100])
      |> G.as_stream([a: 10])
      |> Enum.take(100)
      |> Enum.each(fn v -> assert v in 10..12 end)
    end

    test "recalculate each time" do
      i = int(derived: [ min: fn locals -> locals[:a] end], max: 12)
      { v, i1 } = G.next_value(i, [ a: 10 ])

      assert v in 10..12
      assert i1.min == 10

      { v, i2 } = G.next_value(i1, [ a: 12 ])

      assert v == 12
      assert i2.min == 12
    end
  end

end

