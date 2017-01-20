defmodule Pollution.Generator.Seq do

  @moduledoc false

  @behaviour Pollution.Generator

  alias Pollution.State
  alias Pollution.Generator, as: G

  @state %State {
    type: __MODULE__
  }

  def create(options) when is_list(options) do
    @state
    |> State.set_param(:child_types, options[:of])
  end

  def filters, do: %{}

  def next_value(state = %State{child_types: [ h | t]}, locals) do
    { value, updated_child } = G.next_value(h, locals)
    rotated = Enum.reverse( [ updated_child | Enum.reverse(t)])
    { value, %State{ state | child_types: rotated, last_child: updated_child } }
  end

  def update_constraints(state), do: state


  ###################
  # Shrinking stuff #
  ###################

  # delegate shrinking to the last type we chose
  def params_for_shrink(state = %State{ last_child: last_child }, current) do
    last_child.type.params_for_shrink(state, current)
  end


end
