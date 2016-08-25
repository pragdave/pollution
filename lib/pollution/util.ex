defmodule Pollution.Util do

  @moduledoc false

  def rand_between(min, max) when is_integer(min) and is_integer(max) do
    :rand.uniform(max - min + 1) - 1 + min
  end

  def list_to_map(list) when is_list(list) do
    list |> Enum.with_index |> Enum.into(%{}, &tuple_flip/1)
  end

  def list_to_map(x), do: list_to_map([x])

  defp tuple_flip({v,i}), do: {i,v}

  @compile {:inline, tuple_flip: 1}
  

  def one_of(list) when is_list(list) do
    with len   = length(list),
         index = rand_between(0, len-1),
         value = Enum.at(list, index),
    do:  { value, index }
  end

  def one_of(map) when is_map(map) do
    with len   = map_size(map),
         index = rand_between(0, len-1),
         value = map[index],
    do:  { value, index }
  end

end
