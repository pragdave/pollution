defmodule Pollution.Util do

  @moduledoc false

  def rand_between(min, max) when is_integer(min) and is_integer(max) do
    :rand.uniform(max - min + 1) - 1 + min
  end
  
end
