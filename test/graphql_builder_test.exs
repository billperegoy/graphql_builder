defmodule GraphqlBuilderTest do
  use ExUnit.Case
  doctest GraphqlBuilder

  describe "basic queries" do
    test "without nested fields" do
      query = %{operation: :thoughts, fields: [:id, :name, :thought]}

      expected = """
      query {
        thoughts {
          id,
          name,
          thought
        }
      }
      """

      assert GraphqlBuilder.generate(query) == expected
    end

    test "with nested fields" do
      query = %{
        operation: :orders,
        fields: [:id, :amount, user: [:id, :name, :email, address: [:city, :country]]]
      }

      expected = """
      query {
        orders {
          id,
          amount,
          user {
            id,
            name,
            email,
            address {
              city,
              country
            }
          }
        }
      }
      """

      assert GraphqlBuilder.generate(query) == expected
    end
  end
end
