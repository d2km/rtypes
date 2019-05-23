defmodule RTypes.ExtractorTest do
  use ExUnit.Case
  doctest RTypes.Extractor

  test "basic types" do
    cases = [
      {:any, [], :any},
      {:none, [], :none},
      {:atom, [], :atom},
      {:map, [], :map},
      {:pid, [], :pid},
      {:port, [], :port},
      {:reference, [], :reference},
      {:struct, [], :map},
      {:tuple, [], :tuple},
      {:float, [], :float},
      {:integer, [], :integer},
      {:neg_integer, [], :neg_integer},
      {:non_neg_integer, [], :non_neg_integer},
      {:pos_integer, [], :pos_integer},
      {:list, [{:type, 0, :any, []}], :list},
      {:list, [], :list},
      {:nonempty_list, [{:type, 0, :any, []}], :nonempty_list},
      {:nonempty_list, [], :nonempty_list},
      {:maybe_improper_list, [], :maybe_improper_list},
      {:maybe_improper_list, [{:type, 0, :any, []}, {:type, 0, :any, []}], :maybe_improper_list},
      {:nonempty_improper_list, [{:type, 0, :any, []}, {:type, 0, :any, []}],
       :nonempty_improper_list},
      {:nonempty_maybe_improper_list, [], :nonempty_maybe_improper_list},
      {:nonempty_maybe_improper_list, [{:type, 0, :any, []}, {:type, 0, :any, []}],
       :nonempty_maybe_improper_list}
    ]

    cases
    |> Enum.each(fn {type, type_args, expected_type} ->
      extracted_type =
        RTypes.Extractor.extract_type(
          BasicTypes,
          String.to_atom("type_#{type}"),
          type_args
        )

      assert match?({:type, _, ^expected_type, _}, extracted_type)
    end)
  end
end
