defmodule RTypes.Lambda do
  def build({:type, _line, :any, _args}), do: fn _ -> true end

  def build({:type, _line, :none, _args}) do
    fn _ ->
      raise "attempt to validate bottom type"
    end
  end

  def build({:type, _line, :atom, _args}), do: &is_atom(&1)
  def build({:type, _line, :integer, _args}), do: &is_integer(&1)
  def build({:type, _line, :reference, _args}), do: &is_reference(&1)
  def build({:type, _line, :port, _args}), do: &is_port(&1)
  def build({:type, _line, :pid, _args}), do: &is_pid(&1)
  def build({:type, _line, :float, _args}), do: &is_float(&1)

  ## literals
  def build({:atom, _line, term}),
    do: fn
      ^term -> true
      _ -> false
    end

  def build({:integer, _line, term}),
    do: fn
      ^term -> true
      _ -> false
    end

  ## ranges
  def build({:type, _, :range, [{:integer, _, l}, {:integer, _, u}]}) do
    fn term -> is_integer(term) and term >= l and term <= u end
  end

  ## binary
  def build({:type, _line, :binary, []}), do: fn term -> is_binary(term) end

  ## bitstrings
  def build({:type, _line, :binary, [{:integer, _, 0}, {:integer, _, 0}]}) do
    fn term ->
      is_bitstring(term) and bit_size(term) == 0
    end
  end

  def build({:type, _line, :binary, [{:integer, _, 0}, {:integer, _, units}]}) do
    fn term ->
      is_bitstring(term) && rem(bit_size(term), units) == 0
    end
  end

  def build({:type, _line, :binary, [{:integer, _, size}, _]}) do
    fn term ->
      is_bitstring(term) && bit_size(term) == size
    end
  end

  ## empty list
  def build({:type, _line, nil, _args}), do: fn term -> term == [] end

  ## composite types

  ## lists
  def build({:type, _line, :list, []}), do: &is_list(&1)

  def build({:type, _line, :list, [typ]}) do
    typ? = build(typ)

    fn term ->
      is_list(term) && Enum.all?(term, typ?)
    end
  end

  def build({:type, _line, :nonempty_list, []}), do: fn term -> Enum.count(term) > 0 end

  def build({:type, _line, :nonempty_list, [typ]}) do
    typ? = build(typ)

    fn term ->
      Enum.count(term) > 0 and Enum.all?(term, typ?)
    end
  end

  def build({:type, _line, :maybe_improper_list, []}) do
    fn
      [] -> true
      [_ | _] -> true
      _ -> false
    end
  end

  def build({:type, _line, :maybe_improper_list, [typ1, typ2]}) do
    typ1? = build(typ1)
    typ2? = build(typ2)

    fn
      [] -> true
      [car | cdr] -> typ1?.(car) and typ2?.(cdr)
      _ -> false
    end
  end

  def build({:type, _line, :nonempty_maybe_improper_list, []}) do
    fn
      [_ | _] -> true
      _ -> false
    end
  end

  def build({:type, _line, :nonempty_maybe_improper_list, [typ1, typ2]}) do
    typ1? = build(typ1)
    typ2? = build(typ2)

    fn
      [car | cdr] -> typ1?.(car) and typ2?.(cdr)
      _ -> false
    end
  end

  ## maps
  def build({:type, _line, :map, :any}), do: &is_map(&1)

  def build({:type, _line, :map, typs}) do
    typs? = Enum.map(typs, &build_map_field/1)

    fn term ->
      is_map(term) and Enum.all?(typs?, fn typ? -> typ?.(term) end)
    end
  end

  ## tuples

  def build({:type, _line, :tuple, :any}), do: &is_tuple(&1)

  def build({:type, _line, :tuple, typs}) do
    typs? = Enum.map(typs, &build/1)
    tuple_size = Enum.count(typs)

    fn term ->
      is_tuple(term) and
        tuple_size(term) == tuple_size and
        Enum.all?(Enum.zip(Tuple.to_list(term), typs?), fn {el, typ?} -> typ?.(el) end)
    end
  end

  ## functions

  def build({:type, _line, :fun, [{:type, _, :any}, _]}), do: &is_function(&1)

  def build({:type, _line, :fun, [{:type, _, :product, arg_types}, _]}) do
    arity = Enum.count(arg_types)

    fn term ->
      is_function(term) and
        case :erlang.fun_info(term, :arity) do
          {:arity, ^arity} ->
            true

          _ ->
            false
        end
    end
  end

  def build({:type, _line, :neg_integer, []}) do
    fn term ->
      is_integer(term) and term < 0
    end
  end

  def build({:type, _line, :non_neg_integer, []}) do
    fn term ->
      is_integer(term) and term >= 0
    end
  end

  def build({:type, _line, :pos_integer, []}) do
    fn term ->
      is_integer(term) and term > 0
    end
  end

  def build({:type, _line, :timeout, []}) do
    fn
      :infinity -> true
      term -> is_integer(term) and term >= 0
    end
  end

  def build({:type, _line, :string, []}) do
    fn term ->
      is_list(term) and
        Enum.all?(term, fn
          x when is_integer(x) and x >= 0 and x < 0x10FFFF ->
            true

          _ ->
            false
        end)
    end
  end

  def build({:type, _line, :number, []}), do: &is_number(&1)
  def build({:type, _line, :node, []}), do: &is_atom(&1)

  def build({:type, _line, :no_return, []}) do
    fn _ ->
      raise "attempt to validate bottom type"
    end
  end

  def build({:type, _line, :module, []}), do: &is_atom(&1)

  def build({:type, _, :mfa, []}) do
    fn
      {m, f, a} ->
        is_atom(m) and is_atom(f) and is_integer(a) and a >= 0 and a < 256

      _ ->
        false
    end
  end

  def build({:type, _line, :iolist, []}), do: &is_list(&1)

  def build({:type, _line, :iodata, []}) do
    fn term ->
      is_list(term) or is_binary(term)
    end
  end

  def build({:type, _line, :identifier, []}) do
    fn term ->
      is_pid(term) or is_reference(term) or is_port(term)
    end
  end

  def build({:type, _line, :function, []}), do: &is_function(&1)
  def build({:type, _line, :fun, []}), do: &is_function(&1)

  def build({:type, _line, :byte, []}) do
    fn term ->
      is_integer(term) and term >= 0 and term < 256
    end
  end

  def build({:type, _line, :char, []}) do
    fn term ->
      is_integer(term) and term >= 0 and term < 0x10FFFF
    end
  end

  def build({:type, _line, :boolean, []}), do: &is_boolean(&1)

  def build({:type, _line, :bitstring, []}), do: &is_binary(&1)

  def build({:type, _line, :arity, []}) do
    fn term ->
      is_integer(term) and term >= 0 and term < 256
    end
  end

  def build({:type, _line, :term, []}), do: fn _ -> true end

  def build({:type, _, :union, types}) do
    types? = Enum.map(types, &build/1)

    fn term ->
      Enum.any?(types?, fn typ? -> typ?.(term) end)
    end
  end

  defp build_map_field({:type, _, :map_field_exact, [{:atom, _, field}, val_typ]}) do
    val_typ? = build(val_typ)

    fn term ->
      case Map.fetch(term, field) do
        {:ok, val} -> val_typ?.(val)
        :error -> false
      end
    end
  end

  defp build_map_field({:type, _, :map_field_exact, [field_typ, val_typ]}) do
    field_typ? = build(field_typ)
    val_typ? = build(val_typ)

    fn term ->
      Enum.any?(term, fn {field, val} ->
        field_typ?.(field) and val_typ?.(val)
      end)
    end
  end

  defp build_map_field({:type, _, :map_field_assoc, _}), do: fn _ -> true end
end
