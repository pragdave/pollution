defmodule Pollution.Generator.String do

  @moduledoc false

  alias Pollution.{State, Util}
  alias Pollution.Generator, as: G
  alias Pollution.Shrinker.Params, as: SP

  @defaults %State{
    type:       __MODULE__,
    must_have:  [ "", " " ],
    min: 0,              # string length
    max: 300,
    extra: %{
      char_range: 0..0xd7af
    },
  }



  def create(options) do
    @defaults
    |> State.add_must_have_to_state(options)
    |> add_character_range_to_state(options)
    |> State.add_min_max_length_to_state(options)
    |> update_constraints
  end

  def filters do
    %{
      blank: &blank?/1
    }
  end

  defp blank?(string), do: String.trim(string) == ""

  defp add_character_range_to_state(state, options) do
    with {remove_must_have, range} = character_range_for(options[:chars]) do
      maybe_remove_must_have(remove_must_have, state)
      |> State.add_to_state(:extra, %{ char_range: range })
    end
  end

  defp maybe_remove_must_have(false, state), do: state
  defp maybe_remove_must_have(true, state),  do: %State{ state | must_have: [] }

  defp character_range_for(nil),        do: {false, 0..0xd7af}
  defp character_range_for(:ascii),     do: {false, 0..127}
  defp character_range_for(:digits),    do: {true, ?0..?9}
  defp character_range_for(:lower),     do: {true, ?a..?z}
  defp character_range_for(:printable), do: {true, 32..126}
  defp character_range_for(:upper),     do: {true, ?A..?Z}
  defp character_range_for(:utf),       do: {false, 0..0xd7af}
  defp character_range_for(%Range{} = range) do
    {true, range}
  end
  defp character_range_for(:digit) do
    character_range_for(:digits)
  end


  @doc """
  Return a tuple containing the next value for this type, along with a
  potentially updated type state.

  The next value is chosen randomly from generator_constraints.list
  """
  def next_value(state, _locals) do
    G.after_emptying_must_have(state, fn (state)->
      len = Util.rand_between(state.min, state.max)
      val = generate_chars(state, len)
      {val, state}
    end)
  end

  def update_constraints(state) do
    State.trim_must_have_to_range_based_on(state, &String.length/1)
  end

  defp generate_chars(_, 0), do: ""
  defp generate_chars(state, len) do
    range = state.extra.char_range
    char_generator = fn _n ->
      :rand.uniform(range.last - range.first + 1) + range.first - 1
    end
    Enum.map(1..len, char_generator) |> List.to_string
  end


  ###################
  # Shrinking stuff #
  ###################

  def params_for_shrink(%{ min: min, max: max }, current) do
    %SP{
      low:       min,   # lengths
      high:      max,
      current:   current,
      shrink:    &shrink_one/1,
      backtrack: &shrink_backtrack/1
    }
  end


  def shrink_one(sp = %SP{firsttime: true, current: current}) do
    if (current |> String.to_charlist |> Enum.any?(fn ch -> ch > 127 end)) do
      with len = String.length(current),
           new_string = Stream.cycle(?a..?z) |> Enum.take(len) |> List.to_string,
      do:  %SP{ sp | firsttime: false, current: new_string }
    else
      %SP{ sp | firsttime: false }
    end
  end


  def shrink_one(sp = %SP{low: low, current: current})
  when byte_size(current) == low do
    %SP{ sp | done: true }
  end

  def shrink_one(sp = %SP{current: << _head :: utf8, rest :: binary >>})  do
    %SP{ sp | current: rest }
  end

  def shrink_backtrack(sp = %SP{}) do
    %SP{ sp | done: true }
  end

end
