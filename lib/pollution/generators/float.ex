defmodule Pollution.Generator.Float do

  @moduledoc false

  alias Pollution.State
  alias Pollution.Generator, as: G

  defmodule Limits do
    @moduledoc false
    def min(), do: min(1.0, 2.0, 2.0)
    def min(current, current, last2),  do: last2
    def min(current, last, _last2),    do: min(current/2.0, current, last)
  end

  @min Limits.min

  def epsilon, do: @min

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


  @doc """
  Return a tuple containing the next value for this type, along with a
  potentially updated type state.

  If there are elements in the `must_have` list, return the first of them,
  and return a state where that element has been removed from `must_have`.

  Otherwise return a random value according to the generator constraints.
  """
  def next_value(state, locals) do
    G.after_emptying_must_have(state, fn state ->
      val = :rand.uniform() * (state.max - state.min) + state.min
      {val, state}
    end)
  end

  def update_constraints(state) do
    state |> State.trim_must_have_to_range
  end
end
