defmodule RTypes.Checker do
  @doc """
  Ensure that term corresponds to the given type.

  The function either returns `true` or raises an exception explaining what went
  wrong.
  """
  @spec check!(term(), RType.Extractor.unfolded_type()) :: true | no_return()
  def check!(term, typ) do
    check(term, typ, [])
  end

  ## base types
  defp check(_, {:type, _line, :any, _args}, _ctx), do: true
  ## bottom type has no inhabitants so checking a value againsts the type makes
  ## no sense
  defp check(_, {:type, _line, :none, _args}, ctx) do
    raise "attempt to validate bottom type in the context #{inspect(ctx)}"
  end

  defp check(term, {:type, _line, :atom, _args}, _ctx) when is_atom(term), do: true
  defp check(term, {:type, _line, :integer, _args}, _ctx) when is_integer(term), do: true
  defp check(term, {:type, _line, :reference, _args}, _ctx) when is_reference(term), do: true
  defp check(term, {:type, _line, :port, _args}, _ctx) when is_port(term), do: true
  defp check(term, {:type, _line, :pid, _args}, _ctx) when is_pid(term), do: true
  defp check(term, {:type, _line, :float, _args}, _ctx) when is_float(term), do: true

  ## literals
  defp check(term, {:atom, _line, term}, _ctx), do: true
  defp check(term, {:integer, _line, term}, _ctx), do: true

  ## ranges
  defp check(term, {:type, _, :range, [{:integer, _, l}, {:integer, _, u}]}, _ctx)
       when is_integer(term) and term >= l and term <= u,
       do: true

  ## binary
  defp check(term, {:type, _line, :binary, []}, _ctx) when is_binary(term), do: true

  ## bitstrings
  defp check(term, {:type, _line, :binary, [{:integer, _, 0}, {:integer, _, 0}]}, ctx)
       when is_bitstring(term) do
    if bit_size(term) == 0 do
      true
    else
      raise "term #{inspect(term)} should be an empty bitstring " <>
              "but the acutal size is #{bit_size(term)} in the context #{inspect(ctx)}"
    end
  end

  defp check(term, {:type, _line, :binary, [{:integer, _, 0}, {:integer, _, units}]}, ctx)
       when is_bitstring(term) do
    if rem(bit_size(term), units) == 0 do
      true
    else
      raise "term #{inspect(term)} should have size multiple of #{units} " <>
              "but the acutal size is #{bit_size(term)} in the context #{inspect(ctx)}"
    end
  end

  defp check(term, {:type, _line, :binary, [{:integer, _, size}, _]}, ctx)
       when is_bitstring(term) do
    if bit_size(term) == size do
      true
    else
      raise "term #{inspect(term)} should be a bitstring of size #{size} " <>
              "but the acutal size is #{bit_size(term)} in the context #{inspect(ctx)}"
    end
  end

  ## empty list
  defp check([], {:type, _line, nil, _args}, _ctx), do: true

  ## composite types

  ## lists
  defp check(term, {:type, _line, :list, []}, _ctx) when is_list(term), do: true

  defp check(term, {:type, _line, :list, [typ]}, ctx) when is_list(term) do
    Enum.all?(term, &check(&1, typ, [term | ctx]))
  end

  defp check([_ | _] = _term, {:type, 0, :nonempty_list, []}, _ctx), do: true

  defp check([_ | _] = term, {:type, _line, :nonempty_list, [typ]}, ctx) do
    Enum.all?(term, &check(&1, typ, [term | ctx]))
  end

  defp check([], {:type, _line, :maybe_improper_list, []}, _ctx), do: true
  defp check([_ | _], {:type, _line, :maybe_improper_list, []}, _ctx), do: true
  defp check([], {:type, _line, :maybe_improper_list, [_typ1, _typ2]}, _ctx), do: true

  defp check([car | cdr] = term, {:type, _line, :maybe_improper_list, [typ1, typ2]}, ctx) do
    check(car, typ1, [term | ctx]) && check(cdr, typ2, [term | ctx])
  end

  defp check([_ | _], {:type, _line, :nonempty_maybe_improper_list, []}, _ctx), do: true

  defp check([car | cdr] = term, {:type, _line, :nonempty_maybe_improper_list, [typ1, typ2]}, ctx) do
    check(car, typ1, [term | ctx]) && check(cdr, typ2, [term | ctx])
  end

  ## maps
  defp check(term, {:type, _line, :map, :any}, _ctx) when is_map(term), do: true

  defp check(term, {:type, _line, :map, typs}, ctx) when is_map(term) do
    Enum.all?(typs, fn typ -> check_map_field(term, typ, ctx) end)
  end

  ## tuples

  defp check(term, {:type, _line, :tuple, :any}, _ctx) when is_tuple(term), do: true

  defp check(term, {:type, _line, :tuple, typs}, ctx) when is_tuple(term) do
    if tuple_size(term) == Enum.count(typs) do
      Enum.zip(Tuple.to_list(term), typs)
      |> Enum.all?(fn {el, typ} -> check(el, typ, ctx) end)
    else
      raise "term #{inspect(term)} has different size than expected" <>
              " #{Enum.count(typs)} in the context #{inspect(ctx)}"
    end
  end

  ## functions

  defp check(term, {:type, _line, :fun, [{:type, _, :any}, _]}, _ctx) when is_function(term),
    do: true

  defp check(term, {:type, _line, :fun, [{:type, _, :product, arg_types}, _]}, ctx)
       when is_function(term) do
    arity = Enum.count(arg_types)

    case :erlang.fun_info(term, :arity) do
      {:arity, ^arity} ->
        true

      _ ->
        raise "term #{inspect(term)} is a function of different arity " <>
                "than expected #{arity} in the context #{inspect(ctx)}"
    end

    true
  end

  ## builtins

  defp check(term, {:type, _line, :neg_integer, []}, _ctx) when is_integer(term) and term < 0,
    do: true

  defp check(term, {:type, _line, :non_neg_integer, []}, _ctx)
       when is_integer(term) and term >= 0,
       do: true

  defp check(term, {:type, _line, :pos_integer, []}, _ctx) when is_integer(term) and term > 0,
    do: true

  defp check(:infinity, {:type, _line, :timeout, []}, _ctx), do: true

  defp check(term, {:type, _line, :timeout, []}, _ctx) when is_integer(term) and term >= 0,
    do: true

  defp check(term, {:type, _line, :string, []}, ctx) when is_list(term) do
    Enum.all?(term, fn
      x when is_integer(x) and x >= 0 and x < 0x10FFFF ->
        true

      _ ->
        raise "term #{inspect(term)} does not conform to type 'string' " <>
                "in the context #{inspect(ctx)}"
    end)
  end

  defp check(term, {:type, _line, :number, []}, _ctx) when is_number(term), do: true
  defp check(term, {:type, _line, :node, []}, _ctx) when is_atom(term), do: true

  defp check(_, {:type, _line, :no_return, []}, ctx) do
    raise "attempt to validate bottom type in the context #{inspect(ctx)}"
  end

  defp check(term, {:type, _line, :module, []}, _ctx) when is_atom(term), do: true

  defp check({m, f, a}, {:type, _, :mfa, []}, _ctx)
       when is_atom(m) and is_atom(f) and is_integer(a) and a >= 0 and a < 256,
       do: true

  ## a simplified check, might be too expensive to do full, recursive check
  defp check(term, {:type, _line, :iolist, []}, _ctx) when is_list(term), do: true

  defp check(term, {:type, _line, :iodata, []}, _ctx) when is_list(term) or is_binary(term),
    do: true

  defp check(term, {:type, _line, :identifier, []}, _ctx)
       when is_pid(term) or is_reference(term) or is_port(term),
       do: true

  defp check(term, {:type, _line, :function, []}, _ctx) when is_function(term), do: true
  defp check(term, {:type, _line, :fun, []}, _ctx) when is_function(term), do: true

  defp check(term, {:type, _line, :byte, []}, _ctx)
       when is_integer(term) and term >= 0 and term < 256,
       do: true

  defp check(term, {:type, _line, :char, []}, _ctx)
       when is_integer(term) and term >= 0 and term < 0x10FFFF,
       do: true

  defp check(true, {:type, _line, :boolean, []}, _ctx), do: true
  defp check(false, {:type, _line, :boolean, []}, _ctx), do: true
  defp check(term, {:type, _line, :bitstring, []}, _ctx) when is_binary(term), do: true
  defp check(term, {:type, _line, :binary, []}, _ctx) when is_binary(term), do: true

  defp check(term, {:type, _line, :arity, []}, _ctx)
       when is_integer(term) and term >= 0 and term < 256,
       do: true

  defp check(_term, {:type, _line, :term, []}, _ctx), do: true

  ## unions
  defp check(term, {:type, _, :union, types}, ctx) do
    rv =
      Enum.any?(types, fn typ ->
        try do
          check(term, typ, ctx)
        rescue
          _ ->
            false
        end
      end)

    if rv do
      rv
    else
      raise "term #{inspect(term)} does not match union type " <>
              "#{inspect(types)} in the context #{inspect(ctx)}"
    end
  end

  ## fall-through clauses
  defp check(term, typ, []) do
    raise "term #{inspect(term)} does not conform to type #{inspect(typ)}"
  end

  defp check(term, typ, ctx) do
    raise "term #{inspect(term)} in the context #{inspect(ctx)} " <>
            "does not conform to type #{inspect(typ)}"
  end

  defp check_map_field(
         term,
         {:type, _, :map_field_exact, [{:atom, _, field}, val_typ]},
         ctx
       ) do
    case Map.fetch(term, field) do
      {:ok, val} ->
        check(val, val_typ, [{:map_field, field}, term | ctx])

      :error ->
        raise "field #{field} is not present in #{inspect(term)} in the context #{ctx}"
    end
  end

  defp check_map_field(term, {:type, _, :map_field_exact, [field_typ, val_typ]}, ctx) do
    rv =
      Enum.reduce(true, Map.keys(term), fn {field, val} ->
        try do
          check(field, field_typ, ctx) && check(val, val_typ, ctx)
        catch
          _ -> false
        end
      end)

    if rv do
      rv
    else
      raise "no fields in the map #{inspect(term)} conform to" <>
              " field type #{inspect(field_typ)} and" <>
              " value type #{inspect(val_typ)} in the context #{inspect(ctx)}"
    end
  end

  defp check_map_field(_term, {:type, _, :map_field_assoc, _}, _ctx) do
    # it is not exactly clear how to check the presence of an optional value
    true
  end
end
