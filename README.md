# GraphqlBuilder

This package allows creation of a GraphQL query or mutation string to be created
from an Elixir structure. This allows a more "correct by construction" string
versus manually creating the string by hand. This is currently a very minimal
package only intended to make it easier to generate query strings to be used in
Elixir unit tests. The idea for this package was taken from the
[gql-query-builder](https://github.com/atulmy/gql-query-builder) package written
for node development.

Here are some usage examples:

### Simple Query

```
iex> query = %Query{operation: :thoughts, fields: [:id, :name, :thought]}

iex>  GraphqlBuilder.query(query)
query {
  thoughts {
    id,
    name,
    thought
  }
}

```

### Simple Query with Variables
```

iex> query = %Query{
...>   operation: :thoughts,
...>   fields: [:name, :thought],
...>   variables: [id: 12]
...> }

iex> GraphqlBuilder.query(query)
query {
  thoughts(id: 12) {
    name,
    thought
  }
}

```

### Query with Nested Fields

```

iex> query = %Query{
...>   operation: :orders,
...>   fields: [:id, :amount, user: [:id, :name, :email, address: [:city, :country]]]
...> }

iex> GraphqlBuilder.query(query)
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

```

### Simple Mutation

```
iex> query = %Query{
...>  operation: :thought_create,
...>  variables: [
...>    name: "Tyrion Lannister'",
...>    thought: "I drink and I know things."
...>  ],
...>  fields: [:id]
...>}

iex> GraphqlBuilder.mutation(query)
mutation {
  thought_create(name: "Tyrion Lannister'", thought: "I drink and I know things.") {
    id
  }
}

```
### Mutation With Nested Params

```
iex> query = %Query{
...>   operation: :update_breed,
...>   variables: [
...>     id: 12,
...>     params: [label: "label", abbreviation: "abbreviation"]
...>   ],
...>   fields: [:label, :abbreviation]
...> }

iex> GraphqlBuilder.mutation(query)
mutation {
  update_breed(id: 12, params: {label: "label", abbreviation: "abbreviation"}) {
    label,
    abbreviation
  }
}

```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `graphql_builder` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:graphql_builder, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/graphql_builder](https://hexdocs.pm/graphql_builder).

