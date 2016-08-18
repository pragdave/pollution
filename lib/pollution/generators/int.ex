defmodule Pollution.Generator.Int do

  @moduledoc false

  alias Pollution.{State, Util}
  alias Pollution.Generator, as: G
    alias Pollution.Shrinker.Params, as: SP

  @state %State{
    type:       __MODULE__,
    must_have:  [ 0, -1, 1 ],
    min:      -1_000,
    max:       1_000,
  }



  def create(options) when is_list(options) do

    options = Enum.into(options, %{})

    @state
    |> State.add_derived_to_state(options)
    |> State.add_min_max_to_state(options)
    |> State.add_must_have_to_state(options)
    |> update_constraints()
  end


  @doc """
  Return a tuple containing the next value for this type, along with a
  potentially updated type state.

  If there are elements in the `must_have` list, return the first of them,
  and return a state where that element has been removed from `must_have`.

  Otherwise return a random value according to the generator constraints.
  """
  def next_value(state, _locals) do
    G.after_emptying_must_have(state, fn (state) ->
      val = Util.rand_between(state.min, state.max)
      {val, state}
    end)
  end


  def update_constraints(state) do
    State.trim_must_have_to_range(state)
  end


  def params_for_shrink(%{ min: min, max: max }, current) when current < 0 do
    %SP{
      low: min,
      high: min(max, 0),
      current: current,
      shrink:    &shrink_one/1,
      backtrack: &shrink_backtrack/1
    }
  end

  def params_for_shrink(%{ min: min, max: max }, current) do
    %SP{
      low: max(min, 0),
      high: max,
      current: current,
      shrink:    &shrink_one/1,
      backtrack: &shrink_backtrack/1
    }
  end

  def shrink_one(sp = %SP{ low: current, current: current } ) do
    %SP{ sp | done: true }
  end

  def shrink_one(sp = %SP{ high: current, current: current } ) do
    %SP{ sp | done: true }
  end

  def shrink_one(sp = %SP{ current: 0 } ) do
    %SP{ sp | done: true }
  end

  def shrink_one(sp = %SP{current: current}) when current < 0 do
    %SP{ sp | current: current + 1 }
  end

  def shrink_one(sp = %SP{current: current}) do
    %SP{ sp | current: current - 1 }
  end

  def shrink_backtrack(sp = %SP{current: current}) when current < 0 do
    %SP{ sp | done: true, current: current - 1 }
  end

  def shrink_backtrack(sp = %SP{current: current}) do
    %SP{ sp | done: true, current: current + 1 }
  end

end
