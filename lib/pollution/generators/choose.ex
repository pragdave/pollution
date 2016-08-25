defmodule Pollution.Generator.Choose do

  @moduledoc false

  @behaviour Pollution.Generator
  
  alias Pollution.State
  alias Pollution.Util
  alias Pollution.Generator, as: G

  @state %State {
    type: __MODULE__
  }

  def create(options) when is_list(options) do
    @state
    |> State.set_param(:child_types, Util.list_to_map(options[:from]))
  end

  def next_value(state = %State{child_types: list}, locals) do

    index = :rand.uniform(Enum.count(list)) - 1
    child = list[index]

    { value, updated_child } = G.next_value(child, locals)

    updated_list = Map.put(list, index, updated_child)
    { value, %State{ state | child_types: updated_list, last_child: updated_child } }
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
