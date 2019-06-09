defmodule RTypesTest do
  use ExUnit.Case
  doctest RTypes

  require RTypes

  test "CompexTypes.type_complex_map" do
    f = RTypes.derive_predicate(ComplexTypes, :type_complex_map, [])
    f2 = RTypes.derive_verifier(ComplexTypes, :type_complex_map, [])

    assert f.(%{key1: [], key2: 15})
    assert match?(:ok, f2.(%{key1: [], key2: 15}))
    assert f.(%{key1: [{:ok, "hi"}], key2: 75})
    assert match?(:ok, f2.(%{key1: [{:ok, "hi"}], key2: 75}))

    refute f.(%{key1: [{:ok, "hi"}], key2: -17})
    assert match?({:error,_}, f2.(%{key1: [{:ok, "hi"}], key2: -17}))

    refute f.(%{key1: [{:ok, :blah}], key2: 17})
    assert match?({:error, _}, f2.(%{key1: [{:ok, :blah}], key2: 17}))
  end

  test "ComplexTypes.M.t" do
    f = RTypes.derive_predicate(ComplexTypes.M, :t, [])
    f2 = RTypes.derive_verifier(ComplexTypes.M, :t, [])

    assert f.(%ComplexTypes.M{a: "hi", b: 15})
    assert f2.(%ComplexTypes.M{a: "hi", b: 15})

    refute f.(%{a: "hi", b: 15})
    assert match?({:error, _}, f2.(%{a: "hi", b: 15}))
  end
end
