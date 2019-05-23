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

  defp expand_type_args(args) when is_list(args) do
    Enum.map(args, fn arg ->
      {mod, type_name, type_args} =
        case arg do
          {{:., _, [{:__aliases__, _, [mod]}, type]}, _, type_args} ->
            {mod, type, type_args}

          {{:., _, [mod, type]}, _, type_args} ->
            {mod, type, type_args}

          {type, _, type_args} ->
            {nil, type, type_args}
        end

      {mod, type_name, type_args}

      case mod do
        nil ->
          {:type, 0, type_name, expand_type_args(type_args)}

        _mod_name ->
          {:remote_type, 0, [{:atom, 0, mod}, {:atom, 0, type_name}, expand_type_args(type_args)]}
      end
    end)
  end

  defmacro derive(code) do
    {mod, type_name, args} =
      case quote(do: unquote(code)) do
        {{:., _, [{:__aliases__, _, [mod]}, type]}, _, type_args} ->
          {mod, type, type_args}

        {{:., _, [mod, type]}, _, type_args} ->
          {mod, type, type_args}
      end

    typ = Macro.escape(RTypes.Extractor.extract_type(mod, type_name, expand_type_args(args)))

    quote bind_quoted: [typ: typ] do
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
