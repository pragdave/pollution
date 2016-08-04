
defmodule Pollution.Mixfile do
  use Mix.Project

  @package [
    licenses: ["mit"],
    maintainers: ["Dave Thomas (pragdave) <dave@pragdave.me>"],
    links:       %{
      "Github" => "https://github.com/pragdave/pollution",
      "Docs"   => "https://hexdocs.pm/pollution"
    },
  ]

  @deps []

  @project [
    app:             :pollution,
    version:         "0.1.0",
    elixir:          "~> 1.3",
    build_embedded:  Mix.env == :prod,
    start_permanent: Mix.env == :prod,
    deps:            @deps,
    description:     """
    Construct streams of values by specifying composable generator functions.
    For example list(tuple(like: {atom, string})) will generate a random length
    keyword list with random keys and values. Constraints can be applied at
    all levels.
    """,
    package:         @package
  ]

  @application []

  ############################################################

  def project,     do: @project
  def application, do: @application

end
