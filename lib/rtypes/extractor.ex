defmodule RTypes.Extractor do
  @doc """
  Recursively extract and instantiate AST representation of a type.

  ## Arguments

    * `mod` - module

    * `type_name` - type name

    * `type_args` - arguments, if any, for the type. The arguments should be
      represented as AST, for example, `{:type, 0, :list, []}`

  ## Usage

  ```
    iex> extract_type(:inet, :port_number, [])
    {:type, 102, :range, [{:integer, 102, 0}, {:integer, 102, 65535}]}

    iex> extract_type(Keyword, :t, [{:type, 0, :list, []}])
    {:type, 0, :list, [{:type, 0, :tuple, [{:type, 74, :atom, []}, {:var, 78, :value}]}]}

  ```
  """

  @type type :: {:type, line :: integer(), atom(), [type | value]}
  @type value :: {value_tag :: atom(), line :: integer(), term()}
  @type unfolded_type :: {:type, line :: integer(), atom(), [type | value]}

  @spec extract_type(module(), atom(), [type | value]) :: unfolded_type()
  def extract_type(mod, type_name, type_args) do
    {typ, mod_types} = find_type(mod, type_name, Enum.count(type_args))
    unfold_type(bind_type_vars(typ, type_args), mod_types)
  end

  defp find_type(mod, type_name, arity) do
    mod_types =
      case Code.Typespec.fetch_types(mod) do
        {:ok, types} ->
          Enum.map(types, fn {_, {local_name, typ, params}} ->
            {{local_name, Enum.count(params)}, {typ, params}}
          end)
          |> Enum.into(%{})

        :error ->
          raise "can not extract types from module #{mod}"
      end

    case Map.fetch(mod_types, {type_name, arity}) do
      {:ok, typ} ->
        {typ, mod_types}

      :error ->
        raise "can not find type #{type_name}/#{arity} in module #{mod}"
    end
  end

  defp unfold_type({:type, line, type_name, type_args}, local_types) do
    {:type, line, type_name, unfold_type_args(type_args, local_types)}
  end

  defp unfold_type({:user_type, _linum, user_type, args}, local_types) do
    case Map.fetch(local_types, {user_type, Enum.count(args)}) do
      {:ok, typ} ->
        unfold_type(bind_type_vars(typ, args), local_types)

      :error ->
        raise "user type #{user_type} not found"
    end
  end

  defp unfold_type(
         {:remote_type, _, [{:atom, _, mod}, {:atom, _, type_name}, args]},
         local_types
       ) do
    extract_type(mod, type_name, unfold_type_args(args, local_types))
  end

  ## concrete value
  defp unfold_type({_kind, _line, _val} = value, _) do
    value
  end

  defp unfold_type_args(:any, _), do: :any

  defp unfold_type_args(args, local_types) do
    Enum.map(args, &unfold_type(&1, local_types))
  end

  defp bind_parameters(typ, parameters, type_vars, type_args) do
    vars =
      Enum.zip(type_vars, type_args)
      |> Enum.map(fn {{:var, _, var_name}, var_value} ->
        {var_name, var_value}
      end)
      |> Enum.into(%{})

    case parameters do
      :any ->
        :any

      xs when is_list(xs) ->
        Enum.map(parameters, fn
          {:var, _, var_name} ->
            case Map.fetch(vars, var_name) do
              {:ok, var_value} -> var_value
              :error -> raise "can not bind type variable #{var_name} for type #{inspect(typ)}"
            end

          {:type, line, type_name, parameters1} ->
            bound_parameters = bind_parameters(type_name, parameters1, type_vars, type_args)
            {:type, line, type_name, bound_parameters}

          {:user_type, line, type_name, parameters1} ->
            bound_parameters = bind_parameters(type_name, parameters1, type_vars, type_args)
            {:user_type, line, type_name, bound_parameters}

          # TODO: {:remote_type ...} -> ?

          {_kind, _line, _val} = value ->
            value
        end)
    end
  end

  defp bind_type_vars({{:type, line, type_name, parameters}, type_vars}, type_args) do
    bound_parameters = bind_parameters(type_name, parameters, type_vars, type_args)
    {:type, line, type_name, bound_parameters}
  end

  defp bind_type_vars({{:user_type, line, type_name, parameters}, type_vars}, type_args) do
    bound_parameters = bind_parameters(type_name, parameters, type_vars, type_args)
    {:user_type, line, type_name, bound_parameters}
  end

  defp bind_type_vars({{:remote_type, line, [mod, type_name, parameters]}, type_vars}, type_args) do
    bound_parameters = bind_parameters(type_name, parameters, type_vars, type_args)
    {:remote_type, line, [mod, type_name, bound_parameters]}
  end

  defp bind_type_vars({{:var, _line, _value} = var, [type_var]}, [type_arg]) do
    [typ] = bind_parameters(:var, [var], [type_var], [type_arg])
    typ
  end

  defp bind_type_vars({{_kind, _line, _value} = val, _}, _), do: val
end
