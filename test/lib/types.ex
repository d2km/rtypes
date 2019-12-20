defmodule RTypes.Test.BasicTypes do
  @type type_any :: any()
  @type type_none::none()
  @type type_atom::atom()
  @type type_map::map()
  @type type_pid::pid()
  @type type_port::port()
  @type type_reference::reference()
  @type type_struct::struct()
  @type type_tuple::tuple()
  @type type_float::float()
  @type type_integer::integer()
  @type type_neg_integer::neg_integer()
  @type type_non_neg_integer::non_neg_integer()
  @type type_pos_integer::pos_integer()
  @type type_list(a)::list(a)
  @type type_list::list()
  @type type_nonempty_list(a)::nonempty_list(a)
  @type type_nonempty_list()::nonempty_list()
  @type type_maybe_improper_list()::maybe_improper_list()
  @type type_maybe_improper_list(a, b)::maybe_improper_list(a, b)
  @type type_nonempty_improper_list(a, b)::nonempty_improper_list(a, b)
  @type type_nonempty_maybe_improper_list()::nonempty_maybe_improper_list()
  @type type_nonempty_maybe_improper_list(a, b)::nonempty_maybe_improper_list(a, b)

  @type type_map_keys :: %{key1: type_any(), key2: any()}
  @type type_map_optional :: %{optional(integer()) => any(), required(atom()) => any()}
  @type type_union::atom() | integer()
  @type type_range :: 1..10
  @type type_literal_atom :: :atom
  @type type_literal_integer :: 1
  @type type_concrete_tuple :: {type_integer(), type_float()}
  @type type_empty_list :: []

  ## literals
  @type type_bitstring_empty :: <<>>
  @type type_bitstring_size :: <<_::10>>
  @type type_bitstring_units :: <<_::_*16>>
  @type type_bitstring_size_and_units :: <<_::20, _::_*8>>

  @type type_fun_arity_0 :: (() -> any())
  @type type_fun_arity_2 :: (any(), type_any() -> any())
  @type type_fun_arity_any :: (... -> :inet.port_number())

  @type type_nonempty_list_short_any :: [...]
  @type type_nonempty_list_short_typ :: [any(), ...]
  @type type_kw_list :: [key: any()]

  @type type_empty_map :: %{}
  @type type_empty_tuple :: {}

  ## builtins
  @type type_term :: term()
  @type type_arity :: arity()
  @type type_as_boolean(t) :: as_boolean(t)
  @type type_binary :: binary()
  @type type_bitstring :: bitstring()
  @type type_boolean :: boolean()
  @type type_byte :: byte()
  @type type_char :: char()
  @type type_charlist :: charlist()
  @type type_nonempty_charlist :: nonempty_charlist()
  @type type_fun :: fun()
  @type type_function :: function()
  @type type_identifier :: identifier()
  @type type_iodata :: iodata()
  @type type_iolist :: iolist()
  @type type_keyword :: keyword()
  @type type_keyword(t) :: keyword(t)
  @type type_mfa :: mfa()
  @type type_module :: module()
  @type type_no_return :: no_return()
  @type type_node :: node()
  @type type_number :: number()
  @type type_timeout :: timeout()
end

defmodule RTypes.Test.ComplexTypes do
  @type type_complex_map :: %{
    key1: [RTypes.Test.GenericTypes.type_generic(atom(), String.t())],
    key2: pos_integer()
  }

  @type type_union(a, b) :: {:ok, a} | {:error, b}

  @type type_recursive(a) :: nil | {a, type_recursive(a)}

  defmodule M do
    @enforce_keys [:a, :b]
    defstruct [:a, :b]
    @type t :: %__MODULE__{a: String.t(), b: non_neg_integer()}
  end
end

defmodule RTypes.Test.GenericTypes do
  @type type_generic(a, b) :: {a, b}
  @type type_generic2(a) :: {a, a}
  @type type_instansiated :: type_generic(byte(), any())
  @type type_instansiated2 :: type_generic2(binary())
end

defmodule RTypes.Test.RemoteTypes do
  @type type_remote_generic(a, b) :: RTypes.Test.GenericTypes.type_generic(a, b)
  @type type_remote_existing(a) :: Keyword.t(list(a))
end
