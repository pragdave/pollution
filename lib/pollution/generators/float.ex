defmodule Pollution.Generator.Float do

  @moduledoc false

  alias Pollution.State
  alias Pollution.Generator, as: G
  alias Pollution.Shrinker.Params, as: SP

  defmodule Limits do
    @moduledoc false
    def min(), do: min(1.0, 2.0, 2.0)
    def min(current, current, last2),  do: last2
    def min(current, last, _last2),    do: min(current/2.0, current, last)
  end

  @min Limits.min

  def epsilon, do: @min
  def in_delta(a,b) do
    abs(a - b) < delta_for(a, b)
  end

  def delta_for(a, b) when abs(a + b) > 1 do
    8 * delta_for(a/8, b/8)
  end
  def delta_for(_a, _b), do: 0.0000001

  @defaults %State{
    type:      __MODULE__,
    must_have: [ 0.0, -1.0, 1.0, @min, -@min ],
    min:      -1.0e6,
    max:       1.0e6,
  }


  def create(options) when is_list(options) do
    options = Enum.into(options, %{})

    @defaults
    |> State.add_derived_to_state(options)
    |> State.add_min_max_to_state(options)
    |> State.add_must_have_to_state(options)
    |> update_constraints
  end

  def filters, do: %{}

  @doc """
  Return a tuple containing the next value for this type, along with a
  potentially updated type state.

  If there are elements in the `must_have` list, return the first of them,
  and return a state where that element has been removed from `must_have`.

  Otherwise return a random value according to the generator constraints.
  """
  def next_value(state, _locals) do
    G.after_emptying_must_have(state, fn state ->
      val = :rand.uniform() * (state.max - state.min) + state.min
      {val, state}
    end)
  end

  def update_constraints(state) do
    state |> State.trim_must_have_to_range
  end


  def params_for_shrink(%{ min: min, max: max }, current) do
    %SP{
      current:   current,
      high:      max,
      low:       min,
      shrink:    &shrink_one/1,
      backtrack: &shrink_backtrack/1
    }
  end


  # I don't know if this is useful, but this loop
  # returns a stream of
  #
  #     val, round(val), val/2, round(val/2)
  #
  # the thinking is that the nearest integer is a simpler value
  # than the float, and so might be significant to the shrinking

  # we know value does fail
  def shrink_one(sp = %{ low: low, current: current }) do
    cond do
      in_delta(current, low) ->
        %SP{ sp | done: true }

      # abs(prior_current - Float.round(prior_current)) > delta ->
      #   IO.inspect [ "rounding", prior_current, offset_current ]
      #   IO.inspect { false, Float.round(prior_current) }

      true  ->
        %SP{ sp | high: current, current: (current + low)/2 }
    end
  end

  # know value doesn't fail
  def shrink_backtrack(sp = %{ high: high, current: current }) do
    %SP{ sp | low: current, current: high }
  end
end
