defmodule RTypes.Generator.StreamDataTest do
  use ExUnit.Case
  use ExUnitProperties

  require RTypes
  require RTypes.Generator, as: Generator
  alias RTypes.Generator.StreamData, as: SD
  alias RTypes.Test.BasicTypes
  alias RTypes.Test.ComplexTypes

  property "atom" do
    p? = RTypes.make_predicate(BasicTypes.type_atom())
    v = RTypes.make_validator(BasicTypes.type_atom())
    gen = Generator.make(BasicTypes.type_atom(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "map" do
    p? = RTypes.make_predicate(BasicTypes.type_map())
    v = RTypes.make_validator(BasicTypes.type_map())
    gen = Generator.make(BasicTypes.type_map(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "struct" do
    p? = RTypes.make_predicate(BasicTypes.type_struct())
    v = RTypes.make_validator(BasicTypes.type_struct())
    gen = Generator.make(BasicTypes.type_struct(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "tuple" do
    p? = RTypes.make_predicate(BasicTypes.type_tuple())
    v = RTypes.make_validator(BasicTypes.type_tuple())
    gen = Generator.make(BasicTypes.type_tuple(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "float" do
    p? = RTypes.make_predicate(BasicTypes.type_float())
    v = RTypes.make_validator(BasicTypes.type_float())
    gen = Generator.make(BasicTypes.type_float(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "integer" do
    p? = RTypes.make_predicate(BasicTypes.type_integer())
    v = RTypes.make_validator(BasicTypes.type_integer())
    gen = Generator.make(BasicTypes.type_integer(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "neg_integer" do
    p? = RTypes.make_predicate(BasicTypes.type_neg_integer())
    v = RTypes.make_validator(BasicTypes.type_neg_integer())
    gen = Generator.make(BasicTypes.type_neg_integer(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "non_neg_integer" do
    p? = RTypes.make_predicate(BasicTypes.type_non_neg_integer())
    v = RTypes.make_validator(BasicTypes.type_non_neg_integer())
    gen = Generator.make(BasicTypes.type_non_neg_integer(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "pos_integer" do
    p? = RTypes.make_predicate(BasicTypes.type_pos_integer())
    v = RTypes.make_validator(BasicTypes.type_pos_integer())
    gen = Generator.make(BasicTypes.type_pos_integer(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "list" do
    p? = RTypes.make_predicate(BasicTypes.type_list())
    v = RTypes.make_validator(BasicTypes.type_list())
    gen = Generator.make(BasicTypes.type_list(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "nonempty_list" do
    p? = RTypes.make_predicate(BasicTypes.type_nonempty_list())
    v = RTypes.make_validator(BasicTypes.type_nonempty_list())
    gen = Generator.make(BasicTypes.type_nonempty_list(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "maybe_improper_list" do
    p? = RTypes.make_predicate(BasicTypes.type_maybe_improper_list())
    v = RTypes.make_validator(BasicTypes.type_maybe_improper_list())
    gen = Generator.make(BasicTypes.type_maybe_improper_list(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "nonempty_maybe_improper_list" do
    p? = RTypes.make_predicate(BasicTypes.type_nonempty_maybe_improper_list())
    v = RTypes.make_validator(BasicTypes.type_nonempty_maybe_improper_list())
    gen = Generator.make(BasicTypes.type_nonempty_maybe_improper_list(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "map_keys" do
    p? = RTypes.make_predicate(BasicTypes.type_map_keys())
    v = RTypes.make_validator(BasicTypes.type_map_keys())
    gen = Generator.make(BasicTypes.type_map_keys(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "map_optional" do
    p? = RTypes.make_predicate(BasicTypes.type_map_optional())
    v = RTypes.make_validator(BasicTypes.type_map_optional())
    gen = Generator.make(BasicTypes.type_map_optional(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "union" do
    p? = RTypes.make_predicate(BasicTypes.type_union())
    v = RTypes.make_validator(BasicTypes.type_union())
    gen = Generator.make(BasicTypes.type_union(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "range" do
    p? = RTypes.make_predicate(BasicTypes.type_range())
    v = RTypes.make_validator(BasicTypes.type_range())
    gen = Generator.make(BasicTypes.type_range(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "literal_atom" do
    p? = RTypes.make_predicate(BasicTypes.type_literal_atom())
    v = RTypes.make_validator(BasicTypes.type_literal_atom())
    gen = Generator.make(BasicTypes.type_literal_atom(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "literal_integer" do
    p? = RTypes.make_predicate(BasicTypes.type_literal_integer())
    v = RTypes.make_validator(BasicTypes.type_literal_integer())
    gen = Generator.make(BasicTypes.type_literal_integer(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "concrete_tuple" do
    p? = RTypes.make_predicate(BasicTypes.type_concrete_tuple())
    v = RTypes.make_validator(BasicTypes.type_concrete_tuple())
    gen = Generator.make(BasicTypes.type_concrete_tuple(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "empty_list" do
    p? = RTypes.make_predicate(BasicTypes.type_empty_list())
    v = RTypes.make_validator(BasicTypes.type_empty_list())
    gen = Generator.make(BasicTypes.type_empty_list(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "bitstring_empty" do
    p? = RTypes.make_predicate(BasicTypes.type_bitstring_empty())
    v = RTypes.make_validator(BasicTypes.type_bitstring_empty())
    gen = Generator.make(BasicTypes.type_bitstring_empty(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "bitstring_size" do
    p? = RTypes.make_predicate(BasicTypes.type_bitstring_size())
    v = RTypes.make_validator(BasicTypes.type_bitstring_size())
    gen = Generator.make(BasicTypes.type_bitstring_size(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "bitstring_units" do
    p? = RTypes.make_predicate(BasicTypes.type_bitstring_units())
    v = RTypes.make_validator(BasicTypes.type_bitstring_units())
    gen = Generator.make(BasicTypes.type_bitstring_units(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "bitstring_size_and_units" do
    p? = RTypes.make_predicate(BasicTypes.type_bitstring_size_and_units())
    v = RTypes.make_validator(BasicTypes.type_bitstring_size_and_units())
    gen = Generator.make(BasicTypes.type_bitstring_size_and_units(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "nonempty_list_short_any" do
    p? = RTypes.make_predicate(BasicTypes.type_nonempty_list_short_any())
    v = RTypes.make_validator(BasicTypes.type_nonempty_list_short_any())
    gen = Generator.make(BasicTypes.type_nonempty_list_short_any(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "kw_list" do
    p? = RTypes.make_predicate(BasicTypes.type_kw_list())
    v = RTypes.make_validator(BasicTypes.type_kw_list())
    gen = Generator.make(BasicTypes.type_kw_list(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "empty_map" do
    p? = RTypes.make_predicate(BasicTypes.type_empty_map())
    v = RTypes.make_validator(BasicTypes.type_empty_map())
    gen = Generator.make(BasicTypes.type_empty_map(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "empty_tuple" do
    p? = RTypes.make_predicate(BasicTypes.type_empty_tuple())
    v = RTypes.make_validator(BasicTypes.type_empty_tuple())
    gen = Generator.make(BasicTypes.type_empty_tuple(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "term" do
    p? = RTypes.make_predicate(BasicTypes.type_term())
    v = RTypes.make_validator(BasicTypes.type_term())
    gen = Generator.make(BasicTypes.type_term(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "arity" do
    p? = RTypes.make_predicate(BasicTypes.type_arity())
    v = RTypes.make_validator(BasicTypes.type_arity())
    gen = Generator.make(BasicTypes.type_arity(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "binary" do
    p? = RTypes.make_predicate(BasicTypes.type_binary())
    v = RTypes.make_validator(BasicTypes.type_binary())
    gen = Generator.make(BasicTypes.type_binary(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "boolean" do
    p? = RTypes.make_predicate(BasicTypes.type_boolean())
    v = RTypes.make_validator(BasicTypes.type_boolean())
    gen = Generator.make(BasicTypes.type_boolean(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "byte" do
    p? = RTypes.make_predicate(BasicTypes.type_byte())
    v = RTypes.make_validator(BasicTypes.type_byte())
    gen = Generator.make(BasicTypes.type_byte(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "char" do
    p? = RTypes.make_predicate(BasicTypes.type_char())
    v = RTypes.make_validator(BasicTypes.type_char())
    gen = Generator.make(BasicTypes.type_char(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "charlist" do
    p? = RTypes.make_predicate(BasicTypes.type_charlist())
    v = RTypes.make_validator(BasicTypes.type_charlist())
    gen = Generator.make(BasicTypes.type_charlist(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "nonempty_charlist" do
    p? = RTypes.make_predicate(BasicTypes.type_nonempty_charlist())
    v = RTypes.make_validator(BasicTypes.type_nonempty_charlist())
    gen = Generator.make(BasicTypes.type_nonempty_charlist(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "iodata" do
    p? = RTypes.make_predicate(BasicTypes.type_iodata())
    v = RTypes.make_validator(BasicTypes.type_iodata())
    gen = Generator.make(BasicTypes.type_iodata(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "iolist" do
    p? = RTypes.make_predicate(BasicTypes.type_iolist())
    v = RTypes.make_validator(BasicTypes.type_iolist())
    gen = Generator.make(BasicTypes.type_iolist(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "keyword" do
    p? = RTypes.make_predicate(BasicTypes.type_keyword())
    v = RTypes.make_validator(BasicTypes.type_keyword())
    gen = Generator.make(BasicTypes.type_keyword(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "module" do
    p? = RTypes.make_predicate(BasicTypes.type_module())
    v = RTypes.make_validator(BasicTypes.type_module())
    gen = Generator.make(BasicTypes.type_module(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "number" do
    p? = RTypes.make_predicate(BasicTypes.type_number())
    v = RTypes.make_validator(BasicTypes.type_number())
    gen = Generator.make(BasicTypes.type_number(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "timeout" do
    p? = RTypes.make_predicate(BasicTypes.type_timeout())
    v = RTypes.make_validator(BasicTypes.type_timeout())
    gen = Generator.make(BasicTypes.type_timeout(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "fixed keys map" do
    p? = RTypes.make_predicate(ComplexTypes.type_complex_map())
    v = RTypes.make_validator(ComplexTypes.type_complex_map())
    gen = Generator.make(ComplexTypes.type_complex_map(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "required keys map" do
    p? = RTypes.make_predicate(ComplexTypes.type_required_keys_map())
    v = RTypes.make_validator(ComplexTypes.type_required_keys_map())
    gen = Generator.make(ComplexTypes.type_required_keys_map(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "optional keys map" do
    p? = RTypes.make_predicate(ComplexTypes.type_optional_keys_map())
    v = RTypes.make_validator(ComplexTypes.type_optional_keys_map())
    gen = Generator.make(ComplexTypes.type_optional_keys_map(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end

  property "mixed keys map" do
    p? = RTypes.make_predicate(ComplexTypes.type_mixed_keys_map())
    v = RTypes.make_validator(ComplexTypes.type_mixed_keys_map())
    gen = Generator.make(ComplexTypes.type_mixed_keys_map(), SD)

    check all(val <- gen) do
      assert(p?.(val))
      assert(v.(val) == :ok)
    end
  end
end
