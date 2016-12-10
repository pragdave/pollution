defmodule Pollution.Generator.Atom do

  @moduledoc false

  alias Pollution.{State, VG}
  alias Pollution.Generator, as: G
  alias Pollution.Shrinker.Params, as: SP

  @defaults %State{
    type:       __MODULE__,
    must_have:  [],
    must_not_have: MapSet.new,
    min: 0,                     # atom length
    max: 255,
    extra: %{
      delegate: nil,            # VG.list(min: 0, max: 6)
    },
  }

  def create(options) do
    @defaults
    |> State.add_derived_to_state(options)
    |> State.add_min_max_length_to_state(options)
    |> create_delegate(options)
  end



  @doc """
  Return a tuple containing the next value for this type, along with a
  potentially updated type state.

  The next value is chosen randomly from generator_constraints.list
  """
  def next_value(state, locals) do
    G.after_emptying_must_have(state, fn (state) ->
      { list, list_state } = G.next_value(state.extra.delegate, locals)
      val = List.to_atom(list)
      state = update_delegate(state, list_state)
      {val, state}
    end)
  end

  def update_constraints(state) do
    State.trim_must_have_to_range_based_on(state, &atom_length/1)
  end

  defp atom_length(atom) do
    atom |> Atom.to_string |> String.length
  end

  defp create_delegate(state, options) do
    must_have = convert_must_have(options[:must_have], state.must_have)
    delegate = VG.list(min: state.min,
                       max: state.max,
                       of: VG.int(min: 33, max: 126),
                       must_have: must_have)

    update_delegate(state, delegate)
  end

  defp update_delegate(state, delegate) do
    Map.put(state, :extra, %{ delegate: delegate })
  end

  defp convert_must_have(nil, must_have), do: must_have
  defp convert_must_have(must_haves, _) when is_list(must_haves) do
    must_haves |> Enum.map(&convert_one_must_have/1)
  end

  defp convert_one_must_have(atom) when is_atom(atom),  do: Atom.to_charlist(atom)
  defp convert_one_must_have(str)  when is_binary(str), do: String.to_charlist(str)
  defp convert_one_must_have(list) when is_list(list),  do: list


  ###################
  # Shrinking stuff #
  ###################

  def params_for_shrink(%{ min: min, max: max }, current) do
    %SP{
      low:       min,   # lengths
      high:      max,
      current:   current,
      shrink:    &shrink_one/1,
      backtrack: &shrink_backtrack/1
    }
  end


  def shrink_one(sp = %SP{low: low, current: current}) do
    chars = Atom.to_charlist(current)
    len   = length(chars)

    cond do
      len == low ->
        %SP{ sp | done: true }
      true ->
        %SP{ sp | current: tl(chars) |> List.to_atom }
    end
  end

  def shrink_backtrack(sp = %SP{}) do
    %SP{ sp | done: true }
  end

end
