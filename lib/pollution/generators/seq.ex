defmodule Pollution.Generator.Seq do

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

  def next_value(state = %State{child_types: [ h | t]}, locals) do
    { value, updated_child } = G.next_value(h, locals)
    rotated = Enum.reverse( [ updated_child | Enum.reverse(t)])
    { value, %State{ state | child_types: rotated } }
  end

end
