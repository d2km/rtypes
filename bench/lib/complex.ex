defmodule Complex do
  @type t :: %{
          a: ta(),
          b: tb()
        }

  @type ta ::
          {:tag1, Keyword.t()}
          | {:tag2, {pos_integer(), String.t()}}
          | {:tag3, Keyword.t(arity())}

  @type tb ::
          :nothing
          | {:something, term()}
          | [
              %{
                x: 1..200,
                y: [{pid(), reference()}]
              }
            ]

  def t_value() do
    %{
      a:
        {:tag3,
         1..1000
         |> Enum.map(fn n ->
           {String.to_atom("blah#{n}"), rem(n, 255)}
         end)},
      b:
        1..100
        |> Enum.map(fn n ->
          %{
            x: rem(n, 700),
            y: 1..50 |> Enum.map(fn _ -> {self(), make_ref()} end)
          }
        end)
    }
  end
end
