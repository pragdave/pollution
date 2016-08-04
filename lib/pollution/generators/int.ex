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



  def update_constraints(state) do
    State.trim_must_have_to_range(state)
  end

  # If the constraints are bounded, then use a uniform distribution
  # to pick between them, otherwise use a strongly center weighted one
  # defp add_distribution_to_params(params, options) do
  #   if options[:min] && options[:max] do
  #     Type.add_to_constraints(params, :distribution, Distribution.Uniform)
  #   else
  #     params
  #   end
  # end


end
