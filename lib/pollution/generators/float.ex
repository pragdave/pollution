defmodule Pollution.Generator.Float do

  @moduledoc false

  alias Pollution.State

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
    |> State.trim_must_have_to_range(options)
  end


  @doc """
  Return a tuple containing the next value for this type, along with a
  potentially updated type state.

  If there are elements in the `must_have` list, return the first of them,
  and return a state where that element has been removed from `must_have`.

  Otherwise return a random value according to the generator constraints.
  """
  def next_value(state, locals) do

    state = update_with_derived_values(state, locals)

    case state.must_have do

      [ h | t ] ->
        { h, %State{state | must_have: t} }

      _ ->
        val = :rand.uniform() * (state.max - state.min) + state.min
        {val, state}
    end
  end


  def update_with_derived_values(state=%{derived: derived}, locals) when is_list(derived) do
    Enum.map(derived, fn {k,v} -> { k, v.(locals) } end)
    |> update_state_with_derived_options(state)
  end

  def update_with_derived_values(state, _) do
    state
  end


  defp update_state_with_derived_options(derived, state) do
    state
    |> State.add_min_max_to_state(derived)
    |> State.trim_must_have_to_range(derived)
  end

end
