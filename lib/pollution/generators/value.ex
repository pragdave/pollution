defmodule Pollution.Generator.Value do

  @moduledoc false

  @behaviour Pollution.Generator
  
  alias Pollution.State
  alias Pollution.Shrinker.Params, as: SP

  @state %State {
    type: __MODULE__
  }

  def create([value: value]) do
    %State{ @state | last_value: value }
  end

  def next_value(state, _locals) do
    { state.last_value, state }
  end

  def update_constraints(state), do: state


  ###################
  # Shrinking stuff #
  ###################

  def params_for_shrink(_, current) do
    %SP{
      current: current,
      done:    true,
      shrink:  fn (sp) -> sp end
    }
  end

end
