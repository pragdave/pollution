defmodule Pollution.Generator.Tuple do

  @moduledoc false

  alias Pollution.{State, VG}
  alias Pollution.Generator, as: G
  alias Pollution.Shrinker.Params, as: SP

  @defaults %State{
    type:       __MODULE__,
    must_have:  [],
    must_not_have: MapSet.new,
    child_types: [ VG.seq(of: [VG.value(42)]) ],
    min: 0,                     # tuple length
    max: 6,
    extra: %{
      delegate: nil,            # VG.list(min: 0, max: 6)
    },
  }

  def create(options) do
    @defaults
    |> State.add_min_max_length_to_state(options)
    |> create_delegate(options)
#    |> trim_must_have_to_range
  end



  @doc """
  Return a tuple containing the next value for this type, along with a
  potentially updated type state.

  The next value is chosen randomly from generator_constraints.list
  """
  def next_value(state, locals) do

#    type = update_with_derived_values(type, locals)

    G.after_emptying_must_have(state, fn (state) ->
      { list, list_state } = G.next_value(state.extra.delegate, locals)
      val   = List.to_tuple(list)
      state = update_delegate(state, list_state)
      {val, state}
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


  def shrink_one(sp = %SP{low: low, current: current})
  when tuple_size(current) == low do
    %SP{ sp | done: true }
  end

  def shrink_one(sp = %SP{current: current})  when tuple_size(current) == 0 do
    %SP{ sp | done: true }
  end

  def shrink_one(sp = %SP{current: current})  do
    %SP{ sp | current: current |> Tuple.to_list |> tl |> List.to_tuple }
  end

  def shrink_backtrack(sp = %SP{}) do
    %SP{ sp | done: true }
  end


  ###########
  # Helpers #
  ###########


  defp create_delegate(state, options) do
    with { delegate, fixed_len} = delegate_for(state, options[:like]) do
      update_delegate(state, delegate, fixed_len)
    end
  end

  defp delegate_for(state, nil) do
    { VG.list(min: state.min, max: state.max, of: state.child_types), nil}
  end

  defp delegate_for(state, tuple) when is_tuple(tuple) do
    delegate_for(state, Tuple.to_list(tuple))
  end

  defp delegate_for(_state, list) when is_list(list) do
    with len = length(list),
    do: { VG.list(of: VG.seq(of: list), min: len, max: len), length(list) }
  end

  defp update_delegate(state, delegate) do
    %State{state | extra: %{ delegate: delegate }}
  end

  defp update_delegate(state, delegate, length) do
    %State{state | extra: %{ delegate: delegate }, min: length, max: length}
  end

end
