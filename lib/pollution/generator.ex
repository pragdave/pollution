defmodule Pollution.Generator do

  @moduledoc false

  alias Pollution.State

  @type state :: Pollution.Params.t

  @callback create(Keyword.t) :: state

  @callback next_value(state, Keyword.t) :: { any, state }

  @callback update_constraints(state) :: state

  @callback filters :: %{optional(atom) => (any -> boolean)}


  def next_value(state, locals \\ []) do
    state
    |> State.update_with_derived_values(locals)
    |> state.type.next_value(locals)
  end

  def as_stream(state, locals \\ []) do
    filters =
      state
      |> Map.get(:filters)
      |> Map.values
      |> List.flatten

    state
    |> Stream.unfold(fn state -> next_value(state, locals) end)
    |> reject_filters(filters)
  end

  def after_emptying_must_have(state = %State{must_have: [ h | t ]}, _other_vals) do
    { h, %State{state | must_have: t} }
  end

  def after_emptying_must_have(state, other_vals) do
    other_vals.(state)
  end

  defp reject_filters(stream, []), do: stream
  defp reject_filters(base_stream, filters) do
    Enum.reduce(filters, base_stream, &Stream.reject(&2, &1))
  end

end
