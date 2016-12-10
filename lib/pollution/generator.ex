defmodule Pollution.Generator do

  @moduledoc false

  alias Pollution.State

  @type state :: Pollution.Params.t

  @callback create(Keyword.t) :: state

  @callback next_value(state, Keyword.t) :: { any, state }

  @callback update_constraints(state) :: state



  def next_value(state, locals \\ []) do
    state
    |> State.update_with_derived_values(locals)
    |> state.type.next_value(locals)
    |> next_if_must_not_have
  end

  def as_stream(state, locals \\ []) do
    Stream.unfold(state, fn state -> next_value(state, locals) end)
  end


  def after_emptying_must_have(state = %State{must_have: [ h | t ]}, _other_vals) do
    { h, %State{state | must_have: t} }
  end

  def after_emptying_must_have(state, other_vals) do
    other_vals.(state)
  end

  def next_if_must_not_have(original = {value, state = %{must_not_have: must_not_have}}, locals \\ []) do
    if MapSet.member?(must_not_have, value) do
      next_value(state, locals)
    else
      original
    end
  end

end
