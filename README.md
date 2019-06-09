# RTypes

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
def is_t(x) when is_integer(x) and x >= 0 and x <= 255
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

That's the gist of it.

## Usage

The library defines `make_validator/1` and `make_predicate/1` macros, and
`make_validator/3` and `make_predicate/3` functions which can be used to
build the functions at run time.  The difference between the two is that a
`validator` returns `:ok` or `{:error, reason}` where `reason` explains what went
wrong, while a `predicate` returns only `true` or `false`.

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
  iex> {:error, _reason} = validate_is_kwlist.([1, 2, 3])
  ```

## Implementation

A generated validation function is essentially a walk-the-tree interpreter
of the expanded AST that represents the type. However, instead of evaluating the
AST it applies basic type checks.

A generated predicate uses a different approach. It builds up a chain of
suspended function calls (closures) which mirrors the type's AST. The benchmarks
in `bench/` directory have shown that it works approximately 2x faster than the
interpreted version. The downside is that it provides no explanation or failed
cases.

## Notes

 - The type must be fully instantiated, that is, all the type parameters should
   be of a concrete type.

 - For practical reasons the generated function does not recurse down to
   `iolist()`, making only some simplified tests.

## TODO

 - Handle recursive types.

 - Data generator.

 - Better error messages.
