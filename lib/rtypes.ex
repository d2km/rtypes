defmodule RTypes do
  @moduledoc """
  RTypes is an Elixir library which helps automatically create a validation function for
  a given user type. The function can be used to check the shape of the data after
  de-serialisation or in unit-tests.

  Let's suppose we have a type

  ```elixir
  @type t :: 0..255
  ```

  and we have a value `x`. To ensure that our value corresponds to the type `t` we
  can use the function

  ```elixir
  def t?(x) when is_integer(x) and x >= 0 and x <= 255, do: true
  def t?(_), do: false
  ```

  Now, if we have a compound type

  ```elixir
  @type list_of_ts :: [t]
  ```

  and a value `xs`, we can use `is_list/1` guard on `xs` and then ensure that all
  elements of the list conform to `t`. And if we have a more complex structure

  ```elixir
  @type state(a, b) :: %{key1: {a, b}, key2: list_of_ts()}
  ```

  and a value `s`, we can check that `s` is a map which has keys `key1` and
  `key2`, apply the logic above for the value of `key2` and for any concrete types
  `a` and `b` we can check that he value of `key1` is a tuple of length 2 and its
  elements conform to `a` and `b` respectively. So we just recursively apply those
  checks.

  ## Usage

  The library defines `make_validator/1` and `make_predicate/1` macros, and
  `make_validator/3` and `make_predicate/3` functions which can be used at run
  time. The difference between the two is that a `validator` returns `:ok` or
  `{:error, reason}` where `reason` explains what went wrong, while a
  `predicate` returns only `true` or `false` and is somewhat faster.

  ```elixir
  iex> require RTypes
  iex> port_number? = RTypes.make_predicate(:inet.port_number())
  iex> port_number?.(8080)
  true
  iex> port_number?.(80000)
  false
  iex> validate_is_kwlist = RTypes.make_validator(Keyword, :t, [{:type, 0, :pos_integer, []}])
  iex> validate_is_kwlist.(key1: 4, key2: 5)
  :ok
  iex> match?({:error, _reason}, validate_is_kwlist.([1, 2, 3]))
  true
  ```

  """

  @typedoc "`t:error_decription/1` is a keyword list which details the validation error."
  @type error_description :: [
          {:message, String.t()}
          | {:term, term()}
          | {:ctx, [term()]}
          | {:types, [RType.Extractor.unfolded_type()]}
        ]

  @spec format_error_description(error_description()) :: String.t()
  def format_error_description(desc) do
    "fail to validate term #{inspect(desc[:term])}, reason #{desc[:message]}" <>
      case desc[:types] do
        nil -> ""
        types -> ", types #{inspect(types)}"
      end <>
      case desc[:ctx] do
        nil -> ""
        ctx -> ", in context #{inspect(ctx)}"
      end
  end

  @doc """
  Derive a validtation function for the given type expression.

  ## Usage

  ```
  iex> require RTypes
  iex> validate_port_number = RTypes.make_validator(:inet.port_number())
  iex> validate_port_number.(8080)
  :ok
  iex> match?({:error, _}, validate_port_number.(70000))
  true

  iex> validate_kw_list = RTypes.make_validator(Keyword.t(pos_integer()))
  iex> validate_kw_list.([a: 1, b: 2])
  :ok
  ```

  Note that the macro expects its argument provided as in

  ```
  MyModule.my_type(arg1, arg2)
  ```

  The returned function either returns `:ok` or `{:error, reason}` where
  `reason` details what went wrong.
  """
  defmacro make_validator(code) do
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
        RTypes.Checker.check(term, typ)
      end
    end
  end

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

  @doc """
  Derive a validation function given a module name, type name, and type parameters.

  Type parameters must be of some concrete type.

  ## Example

  ```
  iex> validate_kw_list = RTypes.make_validator(Keyword, :t, [{:type, 0, :pos_integer, []}])
  iex> validate_kw_list.(key1: 4, key2: 5)
  :ok
  ```

  The function returns either `:ok` or `{:error, error_description}` where
  `error_description` details what went wrong.
  """
  @spec make_validator(module(), atom(), [RTypes.Extractor.type()]) ::
          (term -> :ok | {:error, error_description()})
  def make_validator(mod, type_name, type_args) do
    typ = RTypes.Extractor.extract_type(mod, type_name, type_args)

    fn term ->
      RTypes.Checker.check(term, typ)
    end
  end

  @doc """
  Derive a predicate for the given type expression.

  ```
  iex> require RTypes
  iex> non_neg_integer? = RTypes.make_predicate(non_neg_integer())
  iex> non_neg_integer?.(10)
  true
  iex> non_neg_integer?.(0)
  true
  iex> non_neg_integer?.(-3)
  false
  iex> non_neg_integer?.(:ok)
  false
  ```
  """
  defmacro make_predicate(code) do
    type_expr = decompose_and_expand(code, __CALLER__)

    typ =
      case type_expr do
        {mod, type_name, args} ->
          RTypes.Extractor.extract_type(mod, type_name, expand_type_args(args))

        {type_name, args} ->
          {:type, 0, type_name, expand_type_args(args)}
      end

    quote bind_quoted: [typ: Macro.escape(typ)] do
      RTypes.Lambda.build(typ)
    end
  end

  @doc """
  Return a predicate given a module name, type name, and type parameters.

  The predicate behaves the same way as the one produced by `make_predicate/1` macro.
  """
  @spec make_predicate(module(), atom(), [RTypes.Extractor.type()]) :: (any() -> boolean())
  def make_predicate(mod, type_name, type_args) do
    typ = RTypes.Extractor.extract_type(mod, type_name, type_args)
    RTypes.Lambda.build(typ)
  end

  @deprecated "use make_validator/1 instead"
  defmacro derive!(code) do
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
        case RTypes.Checker.check(term, typ) do
          :ok -> true
          {:error, reason} -> raise RTypes.format_error_description(reason)
        end
      end
    end
  end

  @deprecated "use make_validator/3 instead"
  def derive!(mod, type_name, type_args) do
    typ = RTypes.Extractor.extract_type(mod, type_name, type_args)

    fn term ->
      case RTypes.Checker.check(term, typ) do
        :ok -> true
        {:error, reason} -> raise RTypes.format_error_description(reason)
      end
    end
  end

  @deprecated "use make_predicate/1 instead"
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
      RTypes.Lambda.build(typ)
    end
  end

  @deprecated "use make_predicate/3 instead"
  def derive(mod, type_name, type_args) do
    typ = RTypes.Extractor.extract_type(mod, type_name, type_args)
    RTypes.Lambda.build(typ)
  end
end
