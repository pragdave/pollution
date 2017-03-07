defmodule Generator_Constraints.FloatTest do

  use     ExUnit.Case

  alias  Pollution.Generator, as: G
  import Pollution.VG

  alias Pollution.Generator.Float

  describe "creation" do
    test "with no arguments" do
      with f = float() do

        assert  0.0 in f.must_have
        assert -1.0 in f.must_have
        assert  1.0 in f.must_have
  
        assert Float.epsilon  in f.must_have
        assert -Float.epsilon in f.must_have
  
        assert length(f.must_have) == 5
  
        assert is_float(f.min)
        assert is_float(f.max)
  
        assert f.min < f.max
      end
    end
  
    test "with keyword arguments" do
      with f = float(min: 3.125, max: 20.0) do
        assert f.max == 20.0
        assert f.min == 3.125
        assert f.must_have == []
      end
    end

    test "truncates must_have to range" do
      with f = float(min: 1, max: 20) do
        assert f.max == 20
        assert f.min == 1
        assert f.must_have == [ 1.0 ]
      end
    end
    
    test "with keyword arguments including type level constraints" do
      with f = float(min: 3.0, max: 20.0, must_have: [4.5, 5.25, 6.125]) do
        assert f.max == 20.0
        assert f.min == 3.0
        assert f.must_have == [4.5, 5.25, 6.125]
      end
    end
  end

  describe "shortcuts" do
  
    test "positive_float" do
      positive_float()
      |> G.as_stream
      |> Enum.take(100)
      |> Enum.each(fn v ->
        assert is_float(v)
        assert v > 0.0
      end)
    end
    
    test "negative_float" do
      negative_float()
      |> G.as_stream
      |> Enum.take(100)
      |> Enum.each(fn v ->
        assert is_float(v)
        assert v < 0.0
      end)
    end
    
    test "nonnegative_float" do
      positive_float()
      |> G.as_stream
      |> Enum.take(100)
      |> Enum.each(fn v ->
        assert is_float(v)
        assert v >= 0.0
      end)
    end
  end

  describe "derived values" do
    test "are looked up initially" do
      float(derived: [ min: fn locals -> locals[:a] end], max: 12)
      |> G.as_stream([a: 10])
      |> Enum.take(100)
      |> Enum.each(fn v -> assert v >= 10.0 && v <= 12.0 end)
    end


    test "prune must have list" do
      float(derived: [ min: fn locals -> locals[:a] end], max: 12, must_have: [8, 9, 10, 100])
      |> G.as_stream([a: 10])
      |> Enum.take(100)
      |> Enum.each(fn v -> assert v >= 10.0 && v <= 12.0 end)
    end

    test "recalculate each time" do
      f = float(derived: [ min: fn locals -> locals[:a] end], max: 12)
      { v, f1 } = G.next_value(f, [ a: 10 ])

      assert v >= 10.0 && v <= 12.0
      assert f1.min == 10.0

      { v, f2 } = G.next_value(f1, [ a: 12 ])

      assert v == 12
      assert f2.min == 12.0
    end
  end
  
  #
  # describe "values returned" do
  #   test "include must_have values" do
  #     f = float(must_have: [5.0, 5.5, 9.25])
  #     assert f |> Type.as_stream([]) |> Enum.take(3) == [5.0, 5.5, 9.25]
  #   end
  # end
  # 
  # describe "Uniform distribution" do
  #   test "has a mean around the middle" do
  #     f = float(min: 20, max: 40)
  #     assert f.generator_constraints.distribution == Quixir.Distribution.Uniform
  # 
  #     numbers = f |> Type.as_stream([]) |> Enum.take(100)
  #     mean = Enum.sum(numbers) / length(numbers)
  #     assert abs(mean - 30.0) < 2
  #   end
  # end


end
