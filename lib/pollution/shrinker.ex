defmodule Pollution.Shrinker do

  @moduledoc false

  alias Pollution.State

  def shrink_value(current_value, state, locals) do
    state = state
            |> State.update_with_derived_values(locals)
            |> state.type.shrink_value(current_value, locals)

    { current_value, state }
  end

  def shrink_until_done(param_name, env = { code, state, locals }) do
    current_state = state[param_name]
    current_state.type.shrink_until_done(param_name, env)
  end

end

