defmodule RTypes.Checker do
  @doc """
  Ensure that term corresponds to the given type.

  The function either returns `:ok` or `{:error, reason}`, where `reason`
  explains what went wrong.
  """
  @spec check(term(), RTypes.Extractor.unfolded_type()) ::
          :ok | {:error, RTypes.error_description()}
  def check(term, typ) do
    check(term, typ, [])
  end

  ## base types
  defp check(_, {:type, _line, :any, _args}, _ctx), do: :ok
  ## the bottom type has no inhabitants so checking a value againsts the type makes
  ## no sense
  defp check(term, {:type, _line, :none, _args}, ctx) do
    {:error, term: term, message: "attempt to validate term against the bottom type", ctx: ctx}
  end

  defp check(term, {:type, _line, :atom, _args}, _ctx) when is_atom(term), do: :ok
  defp check(term, {:type, _line, :integer, _args}, _ctx) when is_integer(term), do: :ok
  defp check(term, {:type, _line, :reference, _args}, _ctx) when is_reference(term), do: :ok
  defp check(term, {:type, _line, :port, _args}, _ctx) when is_port(term), do: :ok
  defp check(term, {:type, _line, :pid, _args}, _ctx) when is_pid(term), do: :ok
  defp check(term, {:type, _line, :float, _args}, _ctx) when is_float(term), do: :ok

  ## literals
  defp check(term, {:atom, _line, term}, _ctx), do: :ok
  defp check(term, {:integer, _line, term}, _ctx), do: :ok

  ## ranges
  defp check(term, {:type, _, :range, [{:integer, _, l}, {:integer, _, u}]}, _ctx)
       when is_integer(term) and term >= l and term <= u,
       do: :ok

  ## binary
  defp check(term, {:type, _line, :binary, []}, _ctx) when is_binary(term), do: :ok

  ## bitstrings
  defp check(term, {:type, _line, :binary, [{:integer, _, 0}, {:integer, _, 0}]}, ctx)
       when is_bitstring(term) do
    if bit_size(term) == 0 do
      :ok
    else
      {
        :error,
        term: term,
        message: "expected an empty bitstring but the acutal size is #{bit_size(term)}",
        ctx: ctx
      }
    end
  end

  defp check(term, {:type, _line, :binary, [{:integer, _, 0}, {:integer, _, units}]}, ctx)
       when is_bitstring(term) do
    if rem(bit_size(term), units) == 0 do
      :ok
    else
      {:error,
       term: term,
       message:
         "expected bitstring of size multiple of #{units} " <>
           "but the acutal size is #{bit_size(term)}",
       ctx: ctx}
    end
  end

  defp check(term, {:type, _line, :binary, [{:integer, _, size}, _]}, ctx)
       when is_bitstring(term) do
    if bit_size(term) == size do
      :ok
    else
      {:error,
       term: term,
       message:
         "expected a bitstring of size #{size} " <>
           "but the acutal size is #{bit_size(term)}",
       ctx: ctx}
    end
  end

  ## empty list
  defp check([], {:type, _line, nil, _args}, _ctx), do: :ok

  ## composite types

  ## lists
  defp check(term, {:type, _line, :list, []}, _ctx) when is_list(term), do: :ok

  defp check(term, {:type, _line, :list, [typ]}, ctx) when is_list(term) do
    Enum.reduce_while(term, :ok, fn elem, _ ->
      case check(elem, typ, [term | ctx]) do
        :ok -> {:cont, :ok}
        {:error, _} = err -> {:halt, err}
      end
    end)
  end

  defp check([_ | _] = _term, {:type, _line, :nonempty_list, []}, _ctx), do: :ok

  defp check([_ | _] = term, {:type, _line, :nonempty_list, [typ]}, ctx) do
    Enum.reduce_while(term, :ok, fn elem, _ ->
      case check(elem, typ, ctx) do
        :ok -> {:cont, :ok}
        {:error, _} = err -> {:halt, err}
      end
    end)
  end

  defp check([], {:type, _line, :maybe_improper_list, []}, _ctx), do: :ok
  defp check([_ | _], {:type, _line, :maybe_improper_list, []}, _ctx), do: :ok
  defp check([], {:type, _line, :maybe_improper_list, [_typ1, _typ2]}, _ctx), do: :ok

  defp check([car | cdr], {:type, _line, :maybe_improper_list, [typ1, typ2]}, _ctx) do
    check(car, typ1) && check(cdr, typ2)
  end

  defp check([_ | _], {:type, _line, :nonempty_maybe_improper_list, []}, _ctx), do: :ok

  defp check([car | cdr] = term, {:type, _line, :nonempty_maybe_improper_list, [typ1, typ2]}, ctx) do
    check(car, typ1, [term | ctx]) && check(cdr, typ2, [term | ctx])
  end

  ## maps
  defp check(term, {:type, _line, :map, :any}, _ctx) when is_map(term), do: :ok

  defp check(term, {:type, _line, :map, typs}, ctx) when is_map(term) do
    Enum.reduce_while(typs, :ok, fn typ, _ ->
      case check_map_field(term, typ, [term | ctx]) do
        :ok -> {:cont, :ok}
        {:error, _} = err -> {:halt, err}
      end
    end)
  end

  ## tuples

  defp check(term, {:type, _line, :tuple, :any}, _ctx) when is_tuple(term), do: :ok

  defp check(term, {:type, _line, :tuple, typs}, ctx) when is_tuple(term) do
    if tuple_size(term) == Enum.count(typs) do
      Enum.zip(Tuple.to_list(term), typs)
      |> Enum.reduce_while(:ok, fn {el, typ}, _ ->
        case check(el, typ, [term | ctx]) do
          :ok -> {:cont, :ok}
          {:error, _} = err -> {:halt, err}
        end
      end)
    else
      {:error,
       term: term,
       message:
         "the tuple has a different size than the expected size " <>
           " #{Enum.count(typs)}",
       ctx: ctx}
    end
  end

  ## functions

  defp check(term, {:type, _line, :fun, [{:type, _, :any}, _]}, _ctx) when is_function(term),
    do: :ok

  defp check(term, {:type, _line, :fun, [{:type, _, :product, arg_types}, _]}, ctx)
       when is_function(term) do
    arity = Enum.count(arg_types)

    case :erlang.fun_info(term, :arity) do
      {:arity, ^arity} ->
        :ok

      _ ->
        {:error,
         term: term,
         message:
           "term is a function of different arity " <>
             "than the expected arity #{arity}",
         ctx: ctx}
    end

    :ok
  end

  ## builtins

  defp check(term, {:type, _line, :neg_integer, []}, _ctx) when is_integer(term) and term < 0,
    do: :ok

  defp check(term, {:type, _line, :non_neg_integer, []}, _ctx)
       when is_integer(term) and term >= 0,
       do: :ok

  defp check(term, {:type, _line, :pos_integer, []}, _ctx) when is_integer(term) and term > 0,
    do: :ok

  defp check(:infinity, {:type, _line, :timeout, []}, _ctx), do: :ok

  defp check(term, {:type, _line, :timeout, []}, _ctx) when is_integer(term) and term >= 0,
    do: :ok

  defp check(term, {:type, _line, :string, []}, ctx) when is_list(term) do
    Enum.reduce_while(term, :ok, fn
      x, _ when is_integer(x) and x >= 0 and x < 0x10FFFF ->
        {:cont, :ok}

      _, _ ->
        {:error, term: term, message: "term does not conform to type 'string'", ctx: ctx}
    end)
  end

  defp check(term, {:type, _line, :nonempty_string, []}, ctx) when is_list(term) do
    case term do
      [_ | _] ->
        Enum.reduce_while(term, :ok, fn
          x, _ when is_integer(x) and x >= 0 and x < 0x10FFFF ->
            {:cont, :ok}

          _, _ ->
            {:error, term: term, message: "term does not conform to type 'string'", ctx: ctx}
        end)

      _ ->
        {:error, term: term, message: "term does not conform to type 'nonempty_string'", ctx: ctx}
    end
  end

  defp check(term, {:type, _line, :number, []}, _ctx) when is_number(term), do: :ok
  defp check(term, {:type, _line, :node, []}, _ctx) when is_atom(term), do: :ok

  defp check(term, {:type, _line, :no_return, []}, ctx) do
    {:error, term: term, message: "attempt to validate term against the bottom type", ctx: ctx}
  end

  defp check(term, {:type, _line, :module, []}, _ctx) when is_atom(term), do: :ok

  defp check({m, f, a}, {:type, _, :mfa, []}, _ctx)
       when is_atom(m) and is_atom(f) and is_integer(a) and a >= 0 and a < 256,
       do: :ok

  ## a simplified check, might be too expensive to do full, recursive check
  defp check(term, {:type, _line, :iolist, []}, _ctx) when is_list(term), do: :ok

  defp check(term, {:type, _line, :iodata, []}, _ctx) when is_list(term) or is_binary(term),
    do: :ok

  defp check(term, {:type, _line, :identifier, []}, _ctx)
       when is_pid(term) or is_reference(term) or is_port(term),
       do: :ok

  defp check(term, {:type, _line, :function, []}, _ctx) when is_function(term), do: :ok
  defp check(term, {:type, _line, :fun, []}, _ctx) when is_function(term), do: :ok

  defp check(term, {:type, _line, :byte, []}, _ctx)
       when is_integer(term) and term >= 0 and term < 256,
       do: :ok

  defp check(term, {:type, _line, :char, []}, _ctx)
       when is_integer(term) and term >= 0 and term < 0x10FFFF,
       do: :ok

  defp check(true, {:type, _line, :boolean, []}, _ctx), do: :ok
  defp check(false, {:type, _line, :boolean, []}, _ctx), do: :ok
  defp check(term, {:type, _line, :bitstring, []}, _ctx) when is_binary(term), do: :ok
  defp check(term, {:type, _line, :binary, []}, _ctx) when is_binary(term), do: :ok

  defp check(term, {:type, _line, :arity, []}, _ctx)
       when is_integer(term) and term >= 0 and term < 256,
       do: :ok

  defp check(_term, {:type, _line, :term, []}, _ctx), do: :ok

  ## unions
  defp check(term, {:type, _, :union, types}, ctx) do
    err = {:error, term: term, message: "term does not match union type", types: types, ctx: ctx}

    Enum.reduce_while(types, err, fn typ, err ->
      case check(term, typ, ctx) do
        :ok ->
          {:halt, :ok}

        {:error, _} ->
          {:cont, err}
      end
    end)
  end

  ## fall-through clause
  defp check(term, typ, ctx) do
    {:error, term: term, message: "term does not conform to type", types: [typ], ctx: ctx}
  end

  defp check_map_field(
         term,
         {:type, _, :map_field_exact, [{:atom, _, field}, val_typ]},
         ctx
       ) do
    case Map.fetch(term, field) do
      {:ok, val} ->
        check(val, val_typ, [{:map_field, field} | ctx])

      :error ->
        {:error, term: term, message: "field #{field} is not present in the map", ctx: ctx}
    end
  end

  defp check_map_field(term, {:type, _, :map_field_exact, [field_typ, val_typ] = types}, ctx) do
    err =
      {:error,
       term: term,
       message:
         "no fields in the map conform to" <>
           " field type and" <>
           " value type",
       types: types,
       ctx: ctx}

    Enum.reduce_while(Map.keys(term), err, fn field, err ->
      case check(field, field_typ, ctx) do
        :ok ->
          case check(Map.get(term, field), val_typ, [{:map_field, field} | ctx]) do
            :ok -> {:halt, :ok}
            {:error, _} -> {:cont, err}
          end

        {:error, _} ->
          {:cont, err}
      end
    end)
  end

  defp check_map_field(term, {:type, _, :map_field_assoc, [field_typ, val_typ]}, ctx) do
    # for optional fields we deman that if any of the keys correspond
    # to `field_typ` then its value must be of `val_typ`
    Enum.find_value(Map.keys(term), :ok, fn field ->
      case check(field, field_typ, ctx) do
        :ok ->
          case check(Map.get(term, field), val_typ, [{:map_field, field} | ctx]) do
            :ok -> :ok
            {:error, _} = err -> err
          end

        {:error, _} ->
          false
      end
    end)
  end
end
