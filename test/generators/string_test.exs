defmodule Generator.StringTest do

  use ExUnit.Case

  alias  Pollution.Generator, as: G
  import Pollution.VG, only: [ string: 0, string: 1 ]

  def run_test(options, test_code) do
    string(options)
    |> G.as_stream
    |> Enum.take(100)
    |> Enum.each(test_code)
  end

  test "string() returns strings of utf characters" do
    run_test([], fn str->
      assert is_binary(str)
      assert String.valid?(str)
    end)
  end

  test "string() returns ascii if requested" do
    run_test([chars: :ascii], fn str ->
      assert is_binary(str)
      assert String.valid?(str)
      String.to_charlist(str)
      |> Enum.each(fn (ch) -> assert ch in 0..127 end)
    end)
  end


  test "string() returns digits if requested" do
    run_test([chars: :digit], fn str ->
      assert is_binary(str)
      assert String.valid?(str)
      String.to_charlist(str)
      |> Enum.each(fn (ch) -> assert ch in ?0..?9 end)
    end)
  end

  test "string() returns lowercase if requested" do
    run_test([chars: :lower], fn str ->
      assert is_binary(str)
      assert String.valid?(str)
      String.to_charlist(str)
      |> Enum.each(fn (ch) -> assert ch in ?a..?z end)
    end)
  end

  test "string() returns uppercase if requested" do
    run_test([chars: :upper], fn str ->
      assert is_binary(str)
      assert String.valid?(str)
      String.to_charlist(str)
      |> Enum.each(fn (ch) -> assert ch in ?A..?Z end)
    end)
  end

  test "string() returns a range if requested" do
    run_test([chars: ?e..?m], fn str ->
      assert is_binary(str)
      assert String.valid?(str)
      String.to_charlist(str)
      |> Enum.each(fn (ch) -> assert ch in ?e..?m end)
    end)
  end

  describe "must_have" do
    test "for unbounded string returns an empty string and a space" do
      strings = string |> G.as_stream([]) |> Enum.take(2)
      assert "" in strings
      assert " " in strings
    end

    test "for string(min: 1) returns a space" do
      strings = string(min: 1) |> G.as_stream([]) |> Enum.take(1)
      assert " " in strings
    end

    test "for string(max: 0) returns empty string" do
      strings = string(max: 0) |> G.as_stream([]) |> Enum.take(3)
      assert strings == [ "", "", "" ]
    end

    test "superceded by must_not_have, but can overlap" do
      without_empty = string(must_not_have: [""]) |> G.as_stream([]) |> Enum.take(2)
      without_space = string(must_not_have: [" "]) |> G.as_stream([]) |> Enum.take(2)
      without_both = string(must_not_have: ["", " "]) |> G.as_stream([]) |> Enum.take(2)

      refute "" in without_empty
      assert " " in without_empty

      refute " " in without_space
      assert "" in without_space

      refute "" in without_both
      refute " " in without_both
    end

  end
end
