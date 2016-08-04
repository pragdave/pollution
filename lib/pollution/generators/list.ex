defmodule Pollution.Generator.List do

  @moduledoc false

  alias Pollution.State
  alias Pollution.Generator, as: G

  @defaults %State{
    type:        __MODULE__,
    must_have:   [],
    min:         0,    # this is min length
    max:         100,
    child_types: [ Pollution.VG.value(42) ],
  }

  def create(options) do
    options = Enum.into(options, %{})

    @defaults
    |> State.add_min_max_length_to_state(options)
    |> State.add_must_have_to_state(options)
    |> State.add_element_type_to_state(options)
    |> maybe_add_empty_list_to_must_have(options)
  end


  
  @doc """
  Return a tuple containing the next value for this type, along with a
  potentially updated type state.
  
  If there are elements in the `must_have` list, return the first of them,
  and return a state where that element has been removed from `must_have`.
  
  Otherwise return a random value according to the generator constraints.
  """
  def next_value(state, locals) do
    G.after_emptying_must_have(state, fn (state) ->
      populate_list(state, locals)
    end)
  end


  defp populate_list(s = %State{}, locals) do
    len = choose_length(s.min, s.max)
    generator = hd(s.child_types)

    { list, generator } = Enum.reduce(1..len, {[], generator}, fn (_, {result, gen}) ->
      { value, gen } = G.next_value(gen, locals)
      { [ value | result ], gen }
    end)

    { Enum.reverse(list), %State{s | child_types: [ generator ] } }
  end

  defp choose_length(fixed, fixed), do: fixed
  defp choose_length(min, max),     do: Pollution.Util.rand_between(min, max)


  defp maybe_add_empty_list_to_must_have(
        state = %{ min: 0, must_have: [] },
        _options
      )
  do
    %State{ state | must_have: [ [] ]}
  end

  defp maybe_add_empty_list_to_must_have(state, _), do: state

end
