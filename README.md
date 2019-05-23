# RTypes

RTypes is a library which helps automatically create a verification function for
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

The library defines `derive/1` macro and `derive/3` function which can be used
to derive a run-time checker for the given type. The checker function either
returns `true` or throws an exception explaining what went wrong.

### `derive/1` macro

  ```elixir
  iex> require RTypes, as: RTypes
  iex> is_port_number = RTypes.derive(:inet.port_number())
  iex> is_port_number.(8080)
  true
  ```

Note that the macro expects the argument as in `module.type(arg1, arg2)`. That
is a module name followed by `.` and the type name, followed by type parameters
enclosed in parenthesis.

### `derive/3` function

The function expects a module

  ```elixir
  iex> is_keyword_list = RTypes.derive(Keyword, :t, [{:type, 0, :pos_integer, []}])
  iex> is_keyword_list.(key1: 4, key2: 5)
  true
  ```

## Implementation

The generated function is essentially a walk-the-tree interpreter of the
expanded AST that represents the type. However, instead of evaluating the
expression it applies a specific clause of the checker function.

## Notes

 - The type must be fully instantiated, that is, all the type parameters should
   be of a concrete type.

 - For practical reasons the generated function does not recurse down to
   `iolist()`, doing only simplified checks.

## TODO

 - Handle recursive types.

 - Data generator.

 - Better error messages.
