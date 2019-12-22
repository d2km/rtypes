defmodule RTypes.Internal do
  @moduledoc false

  @doc false
  def decompose_and_expand(expr, env) do
    case Macro.decompose_call(expr) do
      {mod, f, args} ->
        {Macro.expand(mod, env), f, Enum.map(args, &decompose_and_expand(&1, env))}

      {f, args} ->
        {f, Enum.map(args, &decompose_and_expand(&1, env))}
    end
  end

  @doc false
  def expand_type_args(args) do
    Enum.map(args, fn arg ->
      case arg do
        {mod, type_name, type_args} ->
          {:remote_type, 0, [{:atom, 0, mod}, {:atom, 0, type_name}, expand_type_args(type_args)]}

        {type_name, type_args} ->
          {:type, 0, type_name, expand_type_args(type_args)}
      end
    end)
  end

end
