defmodule Pollution.VG do

  alias Pollution.Generator.{Any, Choose, Float, Int, List, Seq, String, Tuple, Value}
  alias Pollution.State

#  def any(gen_list), do: Any.create(gen_list)

  @doc """
  Return a stream of random booleans (`true` or `false`).

  ## Example

        iex> bool |> as_stream |> Enum.take(5)
        [true, false, true, true, false]
  """
  def bool(),             do: choose(from: [ value(true), value(false) ])

  def choose(options),    do: Choose.create(options)


  def float(options \\ []), do: Float.create(options)
  def positive_float,       do: Float.create(min: 1.0)
  def negative_float,       do: Float.create(max: -1.0)
  def nonnegative_float,    do: Float.create(min: 0.0)

  def int(options \\ []), do: Int.create(options)
  def positive_int,       do: Int.create(min: 1)
  def negative_int,       do: Int.create(max: -1)
  def nonnegative_int,    do: Int.create(min: 0)


  def list(), do: list([])

  def list(size) when is_integer(size) do
    List.create(min: size, max: size)
  end

  def list(gen = %State{}) do
    List.create(of: gen)
  end

  def list(options), do: List.create(options)

  
  def list(min, max) when is_integer(min) and is_integer(max) do
    List.create(min: min, max: max)
  end



  def pick_one(options) do
    gen = options[:from] |> as_list |> Enum.random
    { val, _ } = Pollution.Generator.next_value(gen, [])
    value(val)
  end



  def seq(options) do
    options
    |> Keyword.put(:of, as_list(options[:of]))
    |> Seq.create
  end


  def string(options \\ []), do: String.create(options)

  def tuple(options \\ []),  do: Tuple.create(options)

  def value(val) do
    Value.create(value: val)
  end




  ###########
  # Helpers #
  ###########

  defp as_list(val) when is_list(val), do: val
  defp as_list(val), do: [val]


end
