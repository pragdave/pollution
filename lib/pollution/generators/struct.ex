defmodule Pollution.Generator.Struct do

  @moduledoc false

  @behaviour Pollution.Generator

  alias Pollution.State
  alias Pollution.VG
  alias Pollution.Generator, as: G
  alias G.Map, as: M

  def create(name) when is_atom(name) do
    try do
      _ = name.__info__(:module)   # is it a module?
    rescue
      _ in [UndefinedFunctionError] ->
        raise "VG.struct(#{inspect name}): parameter is not a Struct"
    end
    create(struct(name))           # yes, assume it's a struct
  end

  def create(s = %{__struct__: name}) do
    s = VG.map(like: meta(s))
    s = put_in(s.type, __MODULE__)
    s = put_in(s.extra[:struct_name], name)
    s
  end

  def filters, do: %{}

  # Convert the values into value generators for their types
  defp meta(s) do
    s |> Map.from_struct |> Enum.map(&generator_for/1)
  end


  # The `generator_for` function converts {k, v} into
  # { k, generator_for(typeof(v))

  defp generator_for(pair) do
    case pair do
      {k, nil}                   -> {k, VG.any}
      {k, v = %State{}}          -> {k, v}
      {k, v} when is_function(v) -> {k, v}
      {k, v} when is_atom(v)     -> {k, VG.atom}
      {k, v} when is_float(v)    -> {k, VG.float}
      {k, v} when is_integer(v)  -> {k, VG.int}
      {k, v} when is_list(v)     -> {k, VG.list}
      {k, v} when is_map(v)      -> {k, VG.map(of: { VG.atom, VG.any })}
      {k, v} when is_binary(v)   -> {k, VG.string}
      {k, v} when is_tuple(v)    -> {k, VG.tuple}
      x ->   raise "Cannot create generator for #{inspect(x)} in struct"
    end
  end

  def next_value(state, locals) do
    { as_map, new_state } = M.next_value(state, locals)
    { struct(state.extra.struct_name, as_map), new_state }
  end

  def update_constraints(state) do
    State.trim_must_have_to_range_based_on(state, &length/1)
  end

  ###################
  # Shrinking stuff #
  ###################

  def params_for_shrink(state, current) do
    M.params_for_shrink(state, current)
  end

end
