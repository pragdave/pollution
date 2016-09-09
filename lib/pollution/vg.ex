defmodule Pollution.VG do

  alias Pollution.Generator.{Atom, Choose, Float, Int, List, Map,
                             Seq, String, Struct, Tuple, Value}
  alias Pollution.State


  @doc """
  Generates a stream of values of any of the types: atom, float, int,
  list, map, string, and tuple. Structs are not included, as they require
  additional information to create.

  If you need finer control over the types and values returned, see
  the `choose/2` function.
  """
  def any, do: choose(from: [ atom, float, int, list, map, string, tuple ])


  @doc """
  Return a stream of atoms. The characters in the atom are drawn from
  the ASCII printable set (space through ~).

  ## Example:

      iex> import Pollution.{Generator, VG}
      iex> atom(max: 10) |> as_stream |> Enum.take(5)
      [:"", :"Kv0{LGp", :"?0HX\"y", :ad, :"DrS=t(Q"]

  ## Options

  * `min:` _length_

    The minimum length of an atom that will be generated (default: 0).

  * `max:` _length_

    The maximum length of an atom that will be generated (default: 255).

  * `must_have:` [ _value,_ … ]

    Values that _must be_ included in the results. There are no must-have
    vaules by default.

  """
  def atom(options \\ []), do: Atom.create(options)

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
  def choose(options), do: Choose.create(options)

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

  @doc """
  Return a stream of lists. Each list will have a random length (within limits),
  and each element in each list will be randomly chosen from the specified types.

  ## Example

      iex> import Pollution.{Generator, VG}
      iex> list(of: bool, max: 7) |> as_stream|> Enum.take(5)
      [
       [],
       [false, false, false],
       [false, true, true, false, true],
       [false, true, true, true, true, false, true],
       [true, true, false, false, false]
      ]

  There are a few special-case constructors:

  * `list(length)`

    Return lists of the given length

  * `list(generator)`

    Return lists whose elements are created by _generator_

        iex> list(bool) |> as_stream|> Enum.take(5)

  Otherwise, pass options:

  * `min:` _length_

    Minimum length of the lists returned. Default 0

  * `max:` _length_

    Maximum length of the lists returned. Default 100

  * `must_have:` [ _value_, … ]

    Values that must be returned. Defaults to returning an empty list
    (so the parameter is `must_have: [ [] ]` if the minimum length is
    zero, nothing otherwise.


  * `of:` _generator_

    Specifies the generator used to populate the lists.

  ## Examples

        iex> import Pollution.{Generator, VG}

        iex> list(of: int, min: 1, max: 5) |> as_stream |> Enum.take(4)
        [[0, -1, 1, -546], [442], [150], [-836, 540, -979]]

        iex> list(of: int, min: 1, max: 5) |> as_stream |> Enum.take(4)
        [[0], [-1, 1, 984, -206], [-246], [433, 125, -757]]

        iex> list(of: choose(from: [value(1), value(2)]), min: 1, max: 5)
        ...>         |> as_stream |> Enum.take(4)
        [[2], [1, 1, 2], [2, 2, 1, 1, 1], [2, 2, 1]]

        iex> list(of: seq(of: [value(1), value(2)]), min: 1, max: 5)
        ...>         |> as_stream |> Enum.take(4)
        [[1, 2], [1, 2, 1, 2], [1], [2, 1]]

  """

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


  @doc """
  Create maps that either mirror a particular structure or that
  contain random numbers of elements.

  To create a stream of maps with a given structure, use the `like:`
  option:

      map(like: %{ name: string, age: int(min:0, max: 130) })

  In this example, the keys are static atoms—each generated map will
  have these two keys. You can also use generators as keys:

      map(like: %{ atom: string })

  This will generate single element maps, where each element has a
  random atom as a key and a random string as a value.

  To create a stream of variable size maps, use `of:`, optionally with
  the `min:` and `max:` options.

      map(of: { atom, string }, min: 3, max: 6)

  This will generate a stream of maps of between 3 and 6 elements
  each, when each element has an atom as a key and a string as a
  value.

  You can use generators such as `choose` and `pick_one` to make
  things more interesting:

      map(of: { atom, choose(from: [string, integer]) }, min: 3, max: 6)

  With this example, some elements will have a string value, and some
  will have an integer value.

  """

  def map(options \\ []) do
    Map.create(options)
  end

  @doc """
  Randomly chooses a generator from the list, and then returns a stream of
  values that it produces. This choice is made only once—call `pick_one`
  again to get a different result.

  ## Examples

      iex> import Pollution.{Generator, VG}
      iex> stream = pick_one(from: [int, bool]) |> as_stream
      iex> Enum.take(stream, 5)
      [0, -1, 1, -223, 72]
      iex> Enum.take(stream, 5)
      [0, -1, 1, -553, 847]
      iex> Enum.take(stream, 5)
      [0, -1, 1, -518, -692]
      iex> Enum.take(stream, 5)
      [0, -1, 1, 580, 668]
      iex> Enum.take(stream, 5)
      [0, -1, 1, -989, -353]
      iex> stream = pick_one(from: [int, bool]) |> as_stream
      iex> Enum.take(stream, 5)
      [true, false, false, false, false]
      iex> Enum.take(stream, 5)
      [false, true, false, false, false]
  """

  def pick_one(options) do
    options[:from] |> as_list |> Enum.random
  end


  @doc """
  Give `seq` a list of generators (using the `of:` option).
  It will cycle through these as it streams values.

  ## Examples

      iex> import Pollution.{Generator, VG}
      iex> seq(of: [int, bool, float]) |> as_stream |> Enum.take(10)
      [0, true, 0.0, -1, true, -1.0, 1, true, 1.0, -702]
  """

  def seq(options) do
    options
    |> Keyword.put(:of, as_list(options[:of]))
    |> Seq.create
  end

  @doc """
  Return a stream of strings of randomly varying length.

  ## Examples

      iex> import Pollution.{Generator, VG}
      iex> string(max: 4) |> as_stream |> Enum.take(5)
      ["", " ", "墍勧", "㘃牸ྥ姷", ""]
      iex> string(chars: :digits, max: 4) |> as_stream |> Enum.take(5)
      ["33", "", "7", "6223", "55"]

  ## Options

  * `min:` _length_

     The minimum length of the returned string (default 0)

  * `max:` _length_

     The maximum length of the returned string (default 300)

  * `chars: :ascii | :digits | :lower | :printable | :upper | :utf`

     The set of characters that may be included in the result:

     | :ascii     |  0..127     |
     | :digits    |  ?0..?9     |
     | :lower     |  ?a..?z     |
     | :printable |  32..126    |
     | :upper     |  ?A..?Z     |
     | :utf       |  0..0xd7af  |

     The default is `:utf8`.

  * `must_have:` _list_

    A list of strings that must be in the result stream. Defaults to `["", "␠"]`,
    filtered by the maximum and minimum lengths.


  """

  def string(options \\ []), do: String.create(options)

  @doc """
  Generate a stream of structs. Before starting, the generator reflects
  on the struct that is passed in, looking at the types of the values
  of each field. It then maps this onto a `map()` generator, using
  appropriate subgenerators for each of those fields.

  For example, given:

       iex> defmodule MyStruct
       iex>    defstruct an_atom: :a, an_int: 0, other: nil
       iex> end

  You could call

      iex> struct(MyStruct)

  As well as passing in the name of a struct, you can pass in
  an instance:

      iex> struct(%MyStruct{})

  In either case, the result would be a stream of MyStructs, as if you
  had called

      map(like: %{ an_atom: atom,
                   an_int:  int,
                   other:   any,
                   __struct__: MyStruct)

  If you supply generators to the struct you pass in, these will be
  used in place of generators for the defaults:

      struct(%MyStruct{an_int: int(min: 20), other: string})
  """

  def struct(template), do: Struct.create(template)

  @doc """
  Generate a stream of tuples. The default is to create tuples of varying sizes
  with varying content, which is unlikely to be useful. You'll more likely want
  to use the `like:` option, which sets a template for the tuples.

  ## Example

      iex> import Pollution.{Generator, VG}
      iex> tuple(like: { value("insert"), string(chars: :upper, max: 10)}) |>
      ...> as_stream |> Enum.take(3)
      [{"insert", "M"}, {"insert", "GFOHZNDER"}, {"insert", "FCDO"}]

  ## Options

  * `min:` _size_  • `max:` _size_

    Set the minimum and maximum sizes of the returned tuples. The defaults are
    0 and 6, but this is overridden by the actual size
    if the `like:` option is specified.

  * `like:` { _template_ }

    A template of generators used to fill the tuple. The generated tuples will
    have the same size as the template, and each element wil be generated from
    the corresponding generator in the template. For example, a `Keyword`
    list could be generated using

        iex> list(of: tuple(like: { atom, string(chars: lower, max: 10) })) |> as_stream |> Enum.take(5)

  """
  def tuple(options \\ []),  do: Tuple.create(options)

  @doc """
  Generates an infinite stream where each element is its parameter.

  ## Example

      iex> import Pollution.{Generator, VG}
      iex> value("nom") |> as_stream |> Enum.take(3)
      ["nom", "nom", "nom"]

  """

  def value(val) do
    Value.create(value: val)
  end




  ###########
  # Helpers #
  ###########

  defp as_list(val) when is_list(val), do: val
  defp as_list(val), do: [val]


end
