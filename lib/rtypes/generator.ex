defmodule RTypes.Generator do
  @moduledoc """
  Generator module provides the `make/4` function and `make/2` macro
  which allow to atomatically derive a data generator to be used with
  property-based frameworks.

  For example, to write a unit test for a pure function with a given
  spec to use with `StreamData` framework one could write something
  along the lines:

  ```elixir
  defmodule MyTest do
    use ExUnit.Case
    use ExUnitProperties

    require RTypes
    require RTypes.Generator, as: Generator

    # @spec f(arg_type) :: result_type
    arg_type_gen = Generator.make(arg_type, Generator.StreamData)
    result_type? = RTypes.make_predicate(result_type)

    property \"for any parameter `f/1` returs value of `result_type`\" do
      check all value <- arg_type_gen do
        assert result_type?.(f(value))
      end
    end
  end
  ```

  The above would generate 100 (by default) values that belong to
  `arg_type` and verify that the result belongs to `result_type`.
  """

  import RTypes.Internal, only: [decompose_and_expand: 2, expand_type_args: 1]

  @doc """
  Make a data generator for the given type and backend.

   - `type` is a literal type expression, e.g. `:inet.port_number()`

   - `backend` is a module implementing a particular property-based
     backend, e.g. `RTypes.Generator.StreamData`
  """
  defmacro make(type, backend) do
    type_expr = decompose_and_expand(type, __CALLER__)

    typ =
      case type_expr do
        {mod, type_name, args} ->
          RTypes.Extractor.extract_type(mod, type_name, expand_type_args(args))

        {type_name, args} ->
          {:type, 0, type_name, expand_type_args(args)}
      end

    quote bind_quoted: [typ: Macro.escape(typ), mod: backend] do
      mod.derive(typ)
    end
  end

  @doc """
  Make a data generator for the given type AST and backend.

    - `mod` is a module name implementing a type,

    - `type_name` is the type name

    - `type_args` is a list of type arguments in AST form

    - `backend` a module implementing a particular property-based
     backend, e.g. `RTypes.Generator.StreamData`

  For example

    ```
    iex> alias RTypes.Generator.StreamData, as: SD
    iex> g = RTypes.Generator.make(:inet, :port_number, [], SD)
    ```
  """
  @spec make(module(), atom(), [RTypes.Extractor.type()], module()) :: generator
        when generator: term()
  def make(mod, type_name, type_args, backend) do
    typ = RTypes.Extractor.extract_type(mod, type_name, type_args)
    backend.derive(typ)
  end
end
