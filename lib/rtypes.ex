defmodule RTypes do
  @moduledoc """
  The module defines the `derive/1` macro which can be used to derive a
  run-time checker for the given type.

  The module also defines a function `derive/3` which can be used at run
  time. However, it must be given arguments as module, type name, and a list of
  type args.

  ## Usage

  ### Using `derive/1` macro

  ```
  iex> require RTypes, as: RTypes
  iex> is_port_number = RTypes.derive(:inet.port_number())
  iex> is_port_number.(8080)
  true
  ```

  Note that the macro expects the argument as in `module.type(arg1, arg2)`. That
  is a module name followed by `.` and the type name, followed by type
  parameters enclosed in parenthesis.

  ### Using `derive/3` function

  ```
  iex> is_keyword_list = RTypes.derive(Keyword, :t, [{:type, 0, :pos_integer, []}])
  iex> is_keyword_list.(key1: 4, key2: 5)
  true
  ```
  """

  defp expand_type_args(args) do
    Enum.map(args, fn arg ->
      case arg do
        {mod, type_name, type_args} ->
          {:remote_type, 0, [{:atom, 0, mod}, {:atom, 0, type_name}, expand_type_args(type_args)]}

        {type_name, type_args} ->
          {:type, 0, type_name, expand_type_args(type_args)}
      end
    end)
  end

  defp decompose_and_expand(expr, env) do
    case Macro.decompose_call(expr) do
      {mod, f, args} ->
        {Macro.expand(mod, env), f, Enum.map(args, &decompose_and_expand(&1, env))}

      {f, args} ->
        {f, Enum.map(args, &decompose_and_expand(&1, env))}
    end
  end

  defmacro derive(code) do
    type_expr = decompose_and_expand(code, __CALLER__)

    typ =
      case type_expr do
        {mod, type_name, args} ->
          RTypes.Extractor.extract_type(mod, type_name, expand_type_args(args))

        {type_name, args} ->
          {:type, 0, type_name, expand_type_args(args)}
      end

    quote bind_quoted: [typ: Macro.escape(typ)] do
      fn term ->
        RTypes.Checker.check!(term, typ)
      end
    end
  end

  def derive(mod, type_name, type_args) do
    typ = RTypes.Extractor.extract_type(mod, type_name, type_args)

    fn term ->
      RTypes.Checker.check!(term, typ)
    end
  end
end
