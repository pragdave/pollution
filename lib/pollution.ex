defmodule Pollution do

  @extras """

  ## API

  See [Pollution.VG](./Pollution.VG.html).

  """

  @moduledoc [
    File.read!("README.md"),
    @extras
  ]
  |> Enum.join

end

