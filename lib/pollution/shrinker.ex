defmodule Pollution.Shrinker.Params do
  defstruct name:      nil,   # the name of this parameter
            current:   0,     # the current value
            high:      0,     # the high point of the range to be searched
            low:       0,     # and the low point
            shrink:    nil,   # a function to shrink one step
            backtrack: nil,   # a function to backtrack
            firsttime: true,  # only true on the first shrink
            done:      false  # dun shrikin'

end

defmodule Pollution.Shrinker do

  @moduledoc false

  def shrink_until_done(param_name, { code, state, locals } ) do
    current_state = state[param_name]
    current_value = locals[param_name]
    current_state.type.params_for_shrink(current_state, current_value)
    |> Map.put(:name, param_name)
    |> shrink(code, locals)
  end

  # We know that the test fails with the current value. See if we
  # can find a smaller value that also fails

  def shrink(params, code, locals) do

    prior_value = params.current

    params = params.shrink.(params)

    new_locals = %{ locals | params.name => params.current }

    cond do
      params.done ->
        prior_value

      code.(new_locals) ->
        # if the assertion fails, we may need to let the shrinker
        # backtrack
        params = params.backtrack.(params)
        new_locals = %{ locals | params.name => params.current }
        shrink(params, code, new_locals)

      true ->
        # assertion still failing. keep looking
        shrink(params, code, new_locals)
    end
  end

  
end

