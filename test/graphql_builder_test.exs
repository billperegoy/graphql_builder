defmodule GraphqlBuilderTest do
  use ExUnit.Case
  import ExUnit.CaptureLog
  alias GraphqlBuilder.Query

  doctest GraphqlBuilder

  describe "queries" do
    test "without nested fields" do
      query = %Query{operation: :thoughts, fields: [:id, :name, :thought]}

      expected = """
      query {
        thoughts {
          id
          name
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
          id
          amount
          user {
            id
            name
            email
            address {
              city
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
          name
          thought
        }
      }
      """

      assert GraphqlBuilder.query(query) == expected
    end

    test "with empty list in query params" do
      query = %Query{
        operation: :thoughts,
        fields: [:name, :thought],
        variables: [options: []]
      }

      expected = """
      query {
        thoughts(options: []) {
          name
          thought
        }
      }
      """

      assert GraphqlBuilder.query(query) == expected
    end

    test "with empty object param" do
      query = %Query{
        operation: :thoughts,
        fields: [:name],
        variables: [params: %{}]
      }

      expected = """
      query {
        thoughts(params: {}) {
          name
        }
      }
      """

      assert GraphqlBuilder.query(query) == expected
    end

    test "with null param" do
      query = %Query{
        operation: :thoughts,
        fields: [:thought],
        variables: [subject: nil]
      }

      expected = """
      query {
        thoughts(subject: null) {
          thought
        }
      }
      """

      assert GraphqlBuilder.query(query) == expected
    end

    test "with integer lists" do
      query = %Query{
        operation: :thoughts,
        fields: [:name, :thought],
        variables: [ids: [12, 13]]
      }

      expected = """
      query {
        thoughts(ids: [12, 13]) {
          name
          thought
        }
      }
      """

      assert GraphqlBuilder.query(query) == expected
    end

    test "with string lists" do
      query = %Query{
        operation: :thoughts,
        fields: [:name, :thought],
        variables: [ids: ["12", "13"]]
      }

      expected = """
      query {
        thoughts(ids: ["12", "13"]) {
          name
          thought
        }
      }
      """

      assert GraphqlBuilder.query(query) == expected
    end

    test "with newlines" do
      query = %Query{
        operation: :shopping_list,
        fields: [:text],
        variables: [text: "milk\norange juice\nstarfruit"]
      }

      expected = ~S"""
      query {
        shopping_list(text: "milk\norange juice\nstarfruit") {
          text
        }
      }
      """

      assert GraphqlBuilder.query(query) == expected
    end

    test "with fragments (deprecated/legacy style)" do
      query = %Query{
        operation: :store_search,
        fields: [{:on, "Product", [:shelf]}, {:on, "Service", [:day]}],
        variables: [text: "cheese"]
      }

      expected = ~S"""
      query {
        store_search(text: "cheese") {
          ... on Product {
            shelf
          }
          ... on Service {
            day
          }
        }
      }
      """

      assert capture_log(fn ->
               assert GraphqlBuilder.query(query) == expected
             end) =~ "Deprecated"
    end

    test "with in-line fragments" do
      query = %Query{
        operation: :store_search,
        fields: [{:frag, "Product", [:shelf]}, {:frag, "Service", [:day]}],
        variables: [text: "cheese"]
      }

      expected = ~S"""
      query {
        store_search(text: "cheese") {
          ... on Product {
            shelf
          }
          ... on Service {
            day
          }
        }
      }
      """

      assert GraphqlBuilder.query(query) == expected
    end

    test "with named fragments" do
      query = %Query{
        operation: :get_thing,
        fields: [frag: "Trinket"]
      }

      expected = ~S"""
      query {
        get_thing {
          ...Trinket
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
          label
          abbreviation
        }
      }
      """

      assert GraphqlBuilder.mutation(query) == expected
    end
  end

  test "with nested lists of objects in mutation arguments" do
    query = %Query{
      operation: :update_breed,
      variables: [
        id: 12,
        params: [things: [[num: 1], [num: "two"]]]
      ],
      fields: [:label, :abbreviation]
    }

    expected = """
    mutation {
      update_breed(id: 12, params: {things: [{num: 1}, {num: "two"}]}) {
        label
        abbreviation
      }
    }
    """

    assert GraphqlBuilder.mutation(query) == expected
  end

  test "with arguments on fields" do
    query = %Query{
      operation: :organization,
      variables: [id: 4],
      fields: [:name, locations: {[region: "west", nice: true], [:name]}]
    }

    expected = """
    query {
      organization(id: 4) {
        name
        locations(region: "west", nice: true) {
          name
        }
      }
    }
    """

    assert GraphqlBuilder.query(query) == expected
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
          label
          abbreviation
        }
      }
      """

      assert GraphqlBuilder.subscription(query) == expected
    end
  end
end
