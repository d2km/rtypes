defmodule Simple do
  @type t :: Keyword.t(:inet.port_number())

  def t_value() do
    1..10000 |> Enum.map(fn n -> {String.to_atom("a#{n}"), n} end)
  end
end
