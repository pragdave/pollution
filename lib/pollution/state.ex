defmodule Pollution.State do

  defstruct(
    type:         __MODULE__,
    last_value:   nil,
    must_have:    [ ],
    child_types:  [ ],
    derived:      [ ],
    min:          nil,
    max:          nil,
    distribution: nil,
    extra:        nil,
  )

  ##############################
  # Helpers used by generators #
  ##############################


  def set_param(state, _key, nil),  do: state
  def set_param(state, key, value), do: Map.put(state, key, value)

  def add_derived_to_state(state, options) do
    state
    |> add_to_state(:derived, options[:derived])
  end
  
  def add_min_max_to_state(state, options) do
    state
    |> add_to_state(:min, options[:min])
    |> add_to_state(:max, options[:max])
  end

  def add_min_max_length_to_state(state, options) do
    state
    |> add_to_state(:min, options[:min])
    |> add_to_state(:max, options[:max])
  end
  
  def add_must_have_to_state(state, options) do
    add_to_state(state, :must_have, options[:must_have])
  end
  
  def add_element_type_to_state(state, options) do
    add_to_state(state, :child_types, maybe_wrap_in_list(options[:of]))
  end
  
  
  def add_to_state(state, _keys, nil),  do: state
  def add_to_state(state, key, value) when is_atom(key) do
    Map.put(state, key, value)
  end
  # 
  # def add_to_constraints(params, _key, nil), do: params
  # def add_to_constraints(params, key, value) when is_atom(key) do
  #   constraints = params.generator_constraints
  #   constraints = Map.put(constraints, key, value)
  #   %{ params | generator_constraints: constraints }
  # end
  # 
  # 
  def trim_must_have_to_range(state, _options) do
    min = state.min
    max = state.max
    updated_must_have =
      state.must_have
      |> Enum.filter(fn val -> val >= min && val <= max end)
    Map.put(state, :must_have, updated_must_have)
  end

  def maybe_wrap_in_list(nil), do: nil
  def maybe_wrap_in_list(l) when is_list(l), do: l
  def maybe_wrap_in_list(v), do: [v]

end

defimpl String.Chars, for: Pollution.State do

  def to_string(val) do
    [
      "\nGenerator: ",
      val.type |> Atom.to_string |> String.split(".") |> Enum.reverse |> hd,
      "(min: #{inspect val.min}, max: #{inspect val.max})\n",
      "must have: #{inspect val.must_have}\n",
      children(val.child_types),
      last_value(val.last_value),
    ]
    |> Enum.join
  end

  defp children([]), do: ""

  defp children(kids) do
    "children: #{kids |> Enum.map(&a_child/1) |> Enum.join}\n"
  end

  defp a_child(child) do
    Regex.replace(~r/\n/, __MODULE__.to_string(child), "\n    ")
  end

  defp last_value(nil), do: ""
  defp last_value(val) do
    "value:     #{inspect val}"
  end
end
