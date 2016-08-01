# Pollution: When Factories Meet Streams

The Pollution library creates streams of values with potentially
complex data types. It is used to support the
[Quixir](https://github.com/pragdave/quixir) property-based testing
library.

Pollution contains a number of _value generators_. These generate
streams of values of a particular type. To make them interesting,
they can be configured, both to constrain the values they produce and
also the subtypes that may be contained in those values.

For example:

`list`

> generates a stream of lists. Each list will be a random size, and
> will contain random values of any type

`int`

> generates a stream of integers

`list(of: int)`

> generates random length lists, and every element will be an integer

`list(of: int(min: 5, max: 21))`

> random length lists of integers between 5 and 21

`list(of: choose(int, float), min: 1, max: 4))`

> lists of between 1 and 4 elements, where each contains either all
> integers or all floats.

Value generators can be composed to arbitrary depths, but be careful
of combinatorial explosions of size:

`list(list(list(list(list))))`

could potentially generate 10 billion values per result.


## Usage

Add to your dependencies:

```elixir
def deps do
  [
    { :pollution, "~> 0.1.0" }
  ]
end
```


The value generator functions live in module `Pollution.VG`. Either
alias it and prefix the function names with `VG`:

``` elixir
defmodule MyModule do

  alias Pollution.VG

  def my_function do
    IO.inspect VG.list(VG.int) |> Enum.take(5)
  end
end
```

or import it and pollute your module with dozens of fun value generators :smile:


``` elixir
defmodule MyModule do

  import Pollution.VG

  def my_function do
    IO.inspect list(tuple(atom, list(int))) |> Enum.take(5)
  end
end
```

## _Must Have_ Values

Most VGs support the option to force certain values to appear in the
result stream. This facility is used in the Quixir testing framework
to ensure that common boundary values are tried alongside more
esoteric values. For example, a stream of integers will start `-1`,
`0`, `1`, and the continue with more random values. A stream of
strings will start `""`, `"⊔"`, a stream of lists with an empty list,
and so on.

These are called _must have_ values, and each VG has its own.

You can set your own _must have_ values for a VG:

    int(must_have: [0, 1, 99, 12345])

    list(must_have: [ [], [ nil ], [ false ] ])

### It Depends What You Mean By _Must_…

A VG will try to include must have values. However, it also checks any
other constraints you may have applied, and alter the must have list
accordingly. For example, the default _must have_ list for integers is
`[-1, 0, 1]`:

    iex> int |> Enum.take(5)
    [ -1, 0, 1, 42, -88484 ]

If we constrain the integer to have a minimum value of zero, the _must
have_ list changes:

    iex> int(min: 0) |> Enum.take(5)
    [ 0, 1, 42, -88484, 663732 ]

You can constrain the _must have_ values away altogether:

    iex> int(min: 5, max: 7) |> Enum.take(5)
    [ 6, 7, 5, 5, 6 ]

This also applies to _must have_ values you set yourself.


## API

`a(«value»)`  _or_  `an(«value»)`

> a stream of the given value. For example

      iex> import Pollution.VG
      iex> a(42) |> Enum.take(5)
      [ 42, 42, 42, 42, 42 ]
      iex> an("aardvark") |> Enum.take(2)
      [ "aardvark", "aardvark" ]


`int(«options»)`

> a stream of integers.

      iex> import Pollution.VG
      iex> int |> Enum.take(7)
      [ -1, 0, 1, 849242, -71212, 34, 9310101 ]


  <details>
  <summary>Options</summary>
  * one

  * two
  </details>





