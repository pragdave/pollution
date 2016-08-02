defmodule Pollution.Generator do

  @type state :: Pollution.Params.t

  @callback create(Keyword.t) :: state

  @callback next_value(state, Keyword.t) :: { any, state }



  def next_value(state, locals \\ []) do
    state.type.next_value(state, locals)
  end

  def as_stream(state, locals \\ []) do
    Stream.unfold(state, fn state -> next_value(state, locals) end)
  end

end

