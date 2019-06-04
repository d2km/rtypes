defmodule RTypesTest do
  use ExUnit.Case
  doctest RTypes

  require RTypes

  test "CompexTypes.type_complex_map" do
    f = RTypes.derive!(ComplexTypes, :type_complex_map, [])
    f2 = RTypes.derive(ComplexTypes, :type_complex_map, [])

    assert f.(%{key1: [], key2: 15})
    assert f2.(%{key1: [], key2: 15})
    assert f.(%{key1: [{:ok, "hi"}], key2: 75})
    assert f2.(%{key1: [{:ok, "hi"}], key2: 75})

    assert_raise RuntimeError, ~r/-17/, fn ->
      f.(%{key1: [{:ok, "hi"}], key2: -17})
    end

    refute f2.(%{key1: [{:ok, "hi"}], key2: -17})

    assert_raise(RuntimeError, ~r/:blah/, fn ->
      f.(%{key1: [{:ok, :blah}], key2: 17})
    end)

    refute f2.(%{key1: [{:ok, :blah}], key2: 17})
  end

  test "ComplexTypes.M.t" do
    f = RTypes.derive!(ComplexTypes.M, :t, [])
    f2 = RTypes.derive(ComplexTypes.M, :t, [])

    assert f.(%ComplexTypes.M{a: "hi", b: 15})
    assert f2.(%ComplexTypes.M{a: "hi", b: 15})

    assert_raise(RuntimeError, ~r/__struct__/, fn ->
      f.(%{a: "hi", b: 15})
    end)

    refute f2.(%{a: "hi", b: 15})
  end
end
