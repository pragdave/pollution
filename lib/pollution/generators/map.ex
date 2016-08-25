defmodule Pollution.Generator.Map do

  @moduledoc false

  alias Pollution.State
  alias Pollution.Generator, as: G
  alias Pollution.Shrinker.Params, as: SP
  alias Pollution.Util
  alias Pollution.VG

  @defaults %State{
    type:        __MODULE__,
    must_have:   [],
    min:         0,    # this is min length
    max:         100,
    child_types: nil
  }

  def create(options) do
    options = Enum.into(options, %{})

    @defaults
    |> State.add_min_max_length_to_state(options)
    |> State.add_must_have_to_state(options)
    |> add_element_types_to_state(options)
    |> maybe_add_empty_map_to_must_have(options)
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
      populate_map(state, locals)
    end)
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


  def shrink_one(sp = %SP{low: low, current: current}) when map_size(current) == low do
    %SP{ sp | done: true }
  end

  def shrink_one(sp = %SP{current: current}) when map_size(current) > 0  do
    %SP{ sp | current: current |> Map.to_list |> tl |> List.to_map }
  end

  def shrink_backtrack(sp = %SP{}) do
    %SP{ sp | done: true }
  end



  def update_constraints(state) do
    State.trim_must_have_to_range_based_on(state, &length/1)
  end

  defp populate_map(s = %State{ extra: %{ fixed_content: true } }, locals) do
    len = choose_length(s.min, s.max)
    { map, child_types } = Enum.reduce(s.child_types, {[], s.child_types},
      fn (next_child, { result, child_types }) ->
        { index, {key_gen, val_gen} } = next_child
        { k, key_gen } = G.next_value(key_gen, locals)
        { v, val_gen } = G.next_value(val_gen, locals)
        child_types = %{ child_types | index => { key_gen, val_gen } }
        { [ { k, v } | result ], child_types }
      end)

    with result    = map |> Enum.into(%{}),
         new_state = %State{s | child_types:  child_types },
    do: { result, new_state }
  end

  defp populate_map(s = %State{}, locals) do
    len = choose_length(s.min, s.max)
    { map, child_types } = Enum.reduce(1..len, {[], s.child_types},
      fn (_, {result, child_types}) ->
        { {key_gen, val_gen}, index } = Util.one_of(child_types)
        { k, key_gen } = G.next_value(key_gen, locals)
        { v, val_gen } = G.next_value(val_gen, locals)
        child_types = %{ child_types | index => { key_gen, val_gen } }
        { [ { k, v } | result ], child_types }
      end)

    with result    = map |> Enum.into(%{}),
         new_state = %State{s | child_types:  child_types },
    do: { result, new_state }
  end

  defp choose_length(fixed, fixed), do: fixed
  defp choose_length(min, max),     do: Pollution.Util.rand_between(min, max)


  defp maybe_add_empty_map_to_must_have(
        state = %{ extra: %{ fixed_content: true }}, _) do
    %State{ state | must_have: [ ]}
  end

  defp maybe_add_empty_map_to_must_have(
        state = %{ min: 0, must_have: [] },
        _options
      )
  do
    %State{ state | must_have: [ %{} ]}
  end

  defp maybe_add_empty_map_to_must_have(state, _), do: state


  def add_element_types_to_state(state, options) do
    like =
      ( options[:like] || options[:of] || %{ VG.atom(min: 3, max: 20) => VG.string } )
      |> Enum.map(&element_from_option/1)
      |> Util.list_to_map

    state
    |> State.add_to_state(:child_types, like)
    |> constrain_state_if_like_option(!!options[:like])
  end

  # If the :like option was given, then we constraint the result
  # to mirror the prototype, and also disable the must_have option

  defp constrain_state_if_like_option(state, true) do
    %State{ state | extra:     %{ fixed_content: true },
                    must_have: []
          }
  end

  defp constrain_state_if_like_option(state, _) do
    state
  end





  defp element_from_option({k, v}) when is_atom(k) do
    element_from_option({VG.value(k), v})
  end

  defp element_from_option({k, v}) do
    { k, v }
  end
end

