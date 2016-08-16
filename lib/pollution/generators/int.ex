defmodule Pollution.Generator.Int do

  @moduledoc false

  alias Pollution.{State, Util}
  alias Pollution.Generator, as: G

  @state %State{
    type:       __MODULE__,
    must_have:  [ 0, -1, 1 ],
    min:      -1_000,
    max:       1_000,
  }


  def create(options) when is_list(options) do

    options = Enum.into(options, %{})

    @state
#    |> add_distribution_to_params(options)
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


  def shrink_until_done(param_name, env = { code, state, locals } ) do
    current_state = state[param_name]
    current_value = locals[param_name]
    shrink_by_scanning(param_name, env, shrink_params(current_state, current_value))
  end



  # We know that the test fails with the current value. See if we
  # can find a smaller value that also fails
  def shrink_by_scanning(_param_name, _env, %{ stop_at: current, current: current}) do
    current
  end
  
  def shrink_by_scanning(param_name, env = { code, state, locals },
                         params = %{ direction: direction, current: current}) do

    new_locals = %{ locals | param_name => current + direction }

    if code.(new_locals) do # does the assertion pass?
      # yes, so we're done (using the previous value for current),
      # because that previous value failed
      current
    else
      # it failed. keep looking
      params = %{ params | current: current + direction }
      shrink_by_scanning(param_name, env, params)
    end
  end


  def shrink_params(%{ min: _min, max: max }, current) when current < 0 do
    %{ direction: 1, stop_at: min(max, 0), current: current }
  end

  def shrink_params(%{ min: min }, current) do
    %{ direction: -1, stop_at: max(min, 0), current: current }
  end

  def update_constraints(state) do
    State.trim_must_have_to_range(state)

  end


end
