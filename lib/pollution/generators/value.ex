defmodule Pollution.Generator.Value do

  @moduledoc false

  @behaviour Pollution.Generator
  
  alias Pollution.State

  @state %State {
    type: __MODULE__
  }

  def create([value: value]) do
    %State{ @state | last_value: value }
  end

  def next_value(state, _locals) do
    { state.last_value, state }
  end
end
