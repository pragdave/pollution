defmodule Pollution.Generator.String do

  alias Pollution.{State, Util}

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
    |> add_character_range_to_state(options)
    |> State.add_min_max_length_to_state(options)
    |> trim_must_have_to_range
  end


  defp add_character_range_to_state(state, options) do
    with {remove_must_have, range} = character_range_for(options[:chars]) do
      if remove_must_have do
        State.add_to_state(state, :must_have, [])
      else
        state
      end
      |> State.add_to_state(:extra, %{ char_range: range })
    end
  end

  defp character_range_for(nil),        do: {false, 0..0xd7af}
  defp character_range_for(:ascii),     do: {false, 0..127}
  defp character_range_for(:printable), do: {true, 32..126}
  defp character_range_for(:digits),    do: {true, ?0..?9}
  defp character_range_for(:upper),     do: {true, ?A..?Z}
  defp character_range_for(:lower),     do: {true, ?a..?z}
  defp character_range_for(%Range{} = range) do
    {true, range}
  end
  defp character_range_for(:digit) do
    character_range_for(:digits)
  end


  defp trim_must_have_to_range(state) do
    min = state.min
    max = state.max

    must_have = Enum.filter(state.must_have, fn str ->
      String.length(str) in min..max
    end)

    State.add_to_state(state, :must_have, must_have)
  end

  @doc """
  Return a tuple containing the next value for this type, along with a
  potentially updated type state.

  The next value is chosen randomly from generator_constraints.list
  """
  def next_value(state, locals) do

#    type = update_with_derived_values(type, locals)

    case state.must_have do

      [ h | t ] ->
        { h, %State{state | must_have: t} }

      _ ->
        with len = Util.rand_between(state.min, state.max),
             val = generate_chars(state, len) do
          {val, state}
        end
    end
  end

  defp generate_chars(_, 0), do: ""
  defp generate_chars(state, len) do
    range = state.extra.char_range
    char_generator = fn n ->
      :rand.uniform(range.last - range.first + 1) + range.first - 1
    end
    Enum.map(1..len, char_generator) |> List.to_string
  end

end