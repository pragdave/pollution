# Pollution: When Factories Meet Streams

The Pollution library creates streams of values with potentially
complex data types. It is used to support the
[https://github.com/pragdave/quixir](Quixir) property-based testing
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


## API

`a(«value»)`  _or_  `a(«value»)`

> Generate a stream of the given value. For example

      iex> import Pollution.VG
      iex> a(42) |> Enum.take(5)
      [ 42, 42, 42, 42, 42 ]
      iex> an("aardvark") |> Enum.take(2)
      [ "aardvark", "aardvark" ]




