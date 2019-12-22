defmodule RTypes.Generator.StreamData do
  @moduledoc """
  The module contains functions to derive generators to be used with StreamData library.
  """

  import StreamData

  @behaviour RTypes.Generator

  @doc """
  Derive a StreamData generator for the specified type AST.
  """
  @spec derive(RTypes.Extractor.type()) :: StreamData.t(v)
        when v: term()
  @impl RTypes.Generator
  def derive({:type, _line, :any, _args}), do: term()

  def derive({:type, _line, :atom, _args}), do: atom(:alphanumeric)

  def derive({:type, _line, :integer, _args}), do: integer()

  def derive({:type, _line, :float, _args}), do: float()

  ## literals
  def derive({:atom, _line, term}), do: constant(term)

  def derive({:integer, _line, term}), do: constant(term)

  ## ranges
  def derive({:type, _, :range, [{:integer, _, l}, {:integer, _, u}]}) do
    integer(l..u)
  end

  ## binary
  def derive({:type, _line, :binary, []}), do: binary()

  ## bitstrings
  def derive({:type, _line, :binary, [{:integer, _, 0}, {:integer, _, 0}]}) do
    bitstring(length: 0)
  end

  def derive({:type, _line, :binary, [{:integer, _, 0}, {:integer, _, units}]}) do
    bind(one_of([constant(0), positive_integer()]), fn count ->
      bitstring(length: units * count)
    end)
  end

  def derive({:type, _line, :binary, [{:integer, _, size}, _]}) do
    bitstring(length: size)
  end

  ## empty list
  def derive({:type, _line, nil, _args}), do: constant([])

  ## composite types

  ## lists
  def derive({:type, _line, :list, []}), do: list_of(term())

  def derive({:type, _line, :list, [typ]}) do
    list_of(derive(typ))
  end

  def derive({:type, _line, :nonempty_list, []}) do
    nonempty(list_of(term()))
  end

  def derive({:type, _line, :nonempty_list, [typ]}) do
    nonempty(list_of(derive(typ)))
  end

  def derive({:type, _line, :maybe_improper_list, []}) do
    maybe_improper_list_of(term(), term())
  end

  def derive({:type, _line, :maybe_improper_list, [typ1, typ2]}) do
    maybe_improper_list_of(derive(typ1), derive(typ2))
  end

  def derive({:type, _line, :nonempty_maybe_improper_list, []}) do
    nonempty_improper_list_of(term(), term())
  end

  def derive({:type, _line, :nonempty_maybe_improper_list, [typ1, typ2]}) do
    nonempty_improper_list_of(derive(typ1), derive(typ2))
  end

  ## maps
  def derive({:type, _line, :map, :any}), do: map_of(term(), term())

  def derive({:type, _line, :map, typs}) do
    typs
    |> Enum.map(&derive_map_field/1)
    |> Enum.reduce(constant(%{}), fn gen, acc_gen ->
      bind({gen, acc_gen}, fn {m, acc} ->
        constant(Map.merge(acc, m))
      end)
    end)
  end

  ## tuples

  def derive({:type, _line, :tuple, :any}) do
    bind(one_of([constant(0), positive_integer()]), fn count ->
      Stream.repeatedly(&term/0)
      |> Enum.take(count)
      |> List.to_tuple()
    end)
  end

  def derive({:type, _line, :tuple, typs}) do
    typs
    |> Enum.map(&derive/1)
    |> List.to_tuple()
    |> tuple()
  end

  def derive({:type, _line, :neg_integer, []}) do
    bind(positive_integer(), fn x -> constant(-1 * x) end)
  end

  def derive({:type, _line, :non_neg_integer, []}) do
    one_of([constant(0), positive_integer()])
  end

  def derive({:type, _line, :pos_integer, []}), do: positive_integer()

  def derive({:type, _line, :timeout, []}) do
    one_of([constant(:infinity), constant(0), positive_integer()])
  end

  def derive({:type, _line, :string, []}) do
    list_of(integer(0..0x10FFFF))
  end

  def derive({:type, _line, :nonempty_string, []}) do
    nonempty(list_of(integer(0..0x10FFFF)))
  end

  def derive({:type, _line, :number, []}), do: one_of([float(), integer()])

  def derive({:type, _line, :module, []}), do: atom(:alphanumeric)

  def derive({:type, _line, :iolist, []}), do: iolist()

  def derive({:type, _line, :iodata, []}), do: iodata()

  def derive({:type, _line, :byte, []}), do: integer(0..255)

  def derive({:type, _line, :char, []}), do: integer(0..0x10FFFF)

  def derive({:type, _line, :boolean, []}), do: boolean()

  def derive({:type, _line, :bitstring, []}), do: bitstring()

  def derive({:type, _line, :arity, []}), do: integer(0..255)

  def derive({:type, _line, :term, []}), do: term()

  def derive({:type, _, :union, types}), do: one_of(Enum.map(types, &derive/1))

  def derive({:type, _line, typ, _args}) do
    raise "can not derive a generator for type #{typ}"
  end

  # required field where key is a known atom
  defp derive_map_field({:type, _, :map_field_exact, [{:atom, _, field}, val_typ]}) do
    fixed_map(%{field => derive(val_typ)})
  end

  # required field
  defp derive_map_field({:type, _, :map_field_exact, [field_typ, val_typ]}) do
    map_of(derive(field_typ), derive(val_typ), length: 1)
  end

  # optional field
  defp derive_map_field({:type, _, :map_field_assoc, [field_typ, val_typ]}) do
    bind(derive(field_typ), fn key ->
      optional_map(%{key => derive(val_typ)})
    end)
  end
end
