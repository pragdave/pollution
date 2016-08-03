defmodule Pollution.VG do

  alias Pollution.Generator.{Any, Choose, Float, Int, List, Seq, String, Tuple, Value}
  alias Pollution.State

#  def any(gen_list), do: Any.create(gen_list)

  @doc """
  Return a stream of random booleans (`true` or `false`).

  ## Example
        iex> import Pollution.{Generator, VG}
        iex> bool |> as_stream |> Enum.take(5)
        [true, false, true, true, false]
  """
  def bool(), do: choose(from: [ value(true), value(false) ])

  @doc """
  Each time a value is needed, randomly choose a generator
  from the list and invoke it.

  ## Example
        iex> import Pollution.{Generator, VG}
        iex> choose(from: [ int(min: 3, max: 7), bool ]) |> as_stream |> Enum.take(5)
        [6, false, 4, true, true]
  """
  def choose(options),    do: Choose.create(options)

  @doc """
  Return a stream of random floating point numbers.

  ## Example

        iex> import Pollution.{Generator, VG}
        iex> float |> as_stream |> Enum.take(5)
        [0.0, -1.0, 1.0, 5.0e-324, -5.0e-324]

  ## Options

  * `min:` _value_

    The minimum value that will be generated (default: -1e6).

  * `max:` _value_

    The maximum value that will be generated (default: 1e6).

  * `must_have:` [ _value,_ … ]

    Values that _must be_ included in the results. The default is

    [ 0.0, -1.0, 1.0, _epsilon_, _-epsilon_ ]

    (where _epsilon_ is the smallest expressible float)

    Must have values are automatically adjusted to account for the
    `min` and `max` values. For example, if you specify `min: 0.5` then
    only the 1.0 must-have value will be generated.

  ## See also

  • `positive_float()`   • `negative_float`   • `non_negative_float`
  """

  def float(options \\ []), do: Float.create(options)

  @doc """
  Return a stream of floats not less than 1.0. (Arguably this should
  be "not less than _epsilon_"). Same as `float(min: 1.0)`
  """

  def positive_float,       do: Float.create(min: 1.0)

  @doc """
  Return a stream of floats not greater than -1.0. (Arguably this should
  be "not greater than _-epsilon_"). Same as `float(max: -1.0)`
  """
  def negative_float,       do: Float.create(max: -1.0)

  @doc """
  Return a stream of floats greater than or equal to zero.
  Same as `float(min: 0.0)`
  """
  
  def nonnegative_float,    do: Float.create(min: 0.0)

  @doc """
  Return a stream of random integers.

  ## Example

        iex> import Pollution.{Generator, VG}
        iex> int |> as_stream |> Enum.take(5)
        [0, -1, 1, 215, -401]

  ## Options

  * `min:` _value_

    The minimum value that will be generated (default: -1000).

  * `max:` _value_

    The maximum value that will be generated (default: 1000).

  * `must_have:` [ _value,_ … ]

    Values that _must be_ included in the results. The default is

    [ 0, -1, 1 ]

    Must have values are automatically adjusted to account for the
    `min` and `max` values. For example, if you specify `min: 0` then
    only the 0 and 1 must-have values will be generated.

  ## See also

  • `positive_int()`   • `negative_int`   • `non_negative_int`
  """

  def int(options \\ []), do: Int.create(options)

  @doc """
  Return a stream of integers not less than 1. Same as `int(min: 1)`
  """

  def positive_int,       do: Int.create(min: 1)

  @doc """
  Return a stream of integers less than 0. Same as `int(max: -1)`
  """
  def negative_int,       do: Int.create(max: -1)

  @doc """
  Return a stream of integers greater than or equal to 0.
  Same as `int(min: 0)`
  """
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
