defmodule GraphqlBuilderTest do
  use ExUnit.Case
  doctest GraphqlBuilder

  alias GraphqlBuilder.Query

  describe "queries" do
    test "without nested fields" do
      query = %Query{operation: :thoughts, fields: [:id, :name, :thought]}

      expected = """
      query {
        thoughts {
          id,
          name,
          thought
        }
      }
      """

      assert GraphqlBuilder.query(query) == expected
    end

    test "with nested fields" do
      query = %Query{
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

      assert GraphqlBuilder.query(query) == expected
    end

    test "with query params" do
      query = %Query{
        operation: :thoughts,
        fields: [:name, :thought],
        variables: [id: 12]
      }

      expected = """
      query {
        thoughts(id: 12) {
          name,
          thought
        }
      }
      """

      assert GraphqlBuilder.query(query) == expected
    end
  end

  describe "mutations" do
    test "without required variables" do
      query = %Query{
        operation: :thought_create,
        variables: [
          name: "Tyrion Lannister'",
          thought: "I drink and I know things."
        ],
        fields: [:id]
      }

      expected = """
      mutation {
        thought_create(name: "Tyrion Lannister'", thought: "I drink and I know things.") {
          id
        }
      }
      """

      assert GraphqlBuilder.mutation(query) == expected
    end

    test "with nested mutation arguments" do
      query = %Query{
        operation: :update_breed,
        variables: [
          id: 12,
          params: [label: "label", abbreviation: "abbreviation"]
        ],
        fields: [:label, :abbreviation]
      }

      expected = """
      mutation {
        update_breed(id: 12, params: {label: "label", abbreviation: "abbreviation"}) {
          label,
          abbreviation
        }
      }
      """

      assert GraphqlBuilder.mutation(query) == expected
    end
  end

  describe "subscriptions" do
    test "without required variables" do
      query = %Query{
        operation: :thought_created,
        variables: [name_like: "Lannister"],
        fields: [:id]
      }

      expected = """
      subscription {
        thought_created(name_like: "Lannister") {
          id
        }
      }
      """

      assert GraphqlBuilder.subscription(query) == expected
    end

    test "with nested mutation arguments" do
      query = %Query{
        operation: :breed_updated,
        variables: [id: 12],
        fields: [:label, :abbreviation]
      }

      expected = """
      subscription {
        breed_updated(id: 12) {
          label,
          abbreviation
        }
      }
      """

      assert GraphqlBuilder.subscription(query) == expected
    end
  end
end
