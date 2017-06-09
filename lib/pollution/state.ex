defmodule Pollution.State do

  @moduledoc false

  defstruct(
    type:          __MODULE__,
    last_value:    nil,
    must_have:     [ ],
    child_types:   [ ],
    last_child:    nil,
    derived:       [ ],
    min:           nil,
    max:           nil,
    distribution:  nil,
    extra:         nil,
    filters:       %{ }
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
  
  def add_filters_to_state(state, options) do
    add_to_state(state, :filters, options[:filters])
  end
  
  def add_element_type_to_state(state, options) do
    add_to_state(state, :child_types, maybe_wrap_in_list(options[:of]))
  end


  def add_to_state(state, _keys, nil),  do: state
  def add_to_state(state, key, value) when is_atom(key) do
    Map.put(state, key, value)
  end


  def update_with_derived_values(state=%{derived: derived}, locals)
  when is_list(derived) and length(derived) > 0 do
    Enum.reduce(derived, state, fn
      {:of, v}, state ->
        Map.put(state, :child_types, maybe_wrap_in_list(v.(locals)))
      {k, v}, state ->
        Map.put(state, k, v.(locals))
    end)
    |> state.type.update_constraints
  end

  def update_with_derived_values(state, _) do
    state
  end

  def trim_must_have_to_range(state) do
    trim_must_have_to_range_based_on(state, &(&1))
  end

  def trim_must_have_to_range_based_on(state, func) do
    trimmer = must_have_trimming_function(state)
    updated_must_have = map_then_filter(state.must_have, trimmer, func)
    %{ state | must_have: updated_must_have }
  end

  defp map_then_filter(enum, filter, mapper) do
    Enum.filter(enum, fn (element) ->
      element |> mapper.() |> filter.()
    end)
  end

  defp must_have_trimming_function(%__MODULE__{ min: min, max: max} = state) do
    fn limit -> limit >= min && limit <= max end
  end

  def trim_must_have_to_child_types(state) do
    case state.child_types do
      [child_type] ->
        new_must_have = Enum.map(state.must_have, fn
          (must_have) ->
            shadowed_must_have_state = %{ child_type | must_have: must_have }
            new_state = trim_must_have_to_range(shadowed_must_have_state)
            new_state.must_have
        end)
        %{ state | must_have: new_must_have }
      _ -> state
    end
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

# defimpl Inspect, for: Pollution.State do
#   def inspect(dict, _opts), do: to_string(dict)
# end
