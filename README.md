# GraphqlBuilder

[![Module Version](https://img.shields.io/hexpm/v/graphql_builder.svg)](https://hex.pm/packages/graphql_builder)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/graphql_builder/)
[![Total Download](https://img.shields.io/hexpm/dt/graphql_builder.svg)](https://hex.pm/packages/graphql_builder)
[![License](https://img.shields.io/hexpm/l/graphql_builder.svg)](https://github.com/billperegoy/graphql_builder/blob/master/LICENSE.md)
[![Last Updated](https://img.shields.io/github/last-commit/billperegoy/graphql_builder.svg)](https://github.com/billperegoy/graphql_builder/commits/master)

This package allows creation of a GraphQL query or mutation string to be created
from an Elixir structure.

This allows a more "correct by construction" string versus manually creating
the string by hand. This is currently a very minimal package only intended to
make it easier to generate query strings to be used in Elixir unit tests. The
idea for this package was taken from the
[gql-query-builder](https://github.com/atulmy/gql-query-builder) package
written for node development.

## Installation

The package can be installed by adding `:graphql_builder` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:graphql_builder, "~> 0.3.0"}
  ]
end
```

## Usage

Here are some usage examples:

### Simple Query

```elixir
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

```elixir
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

```elixir
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

```elixir
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

```elixir
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

## Copyright and License

Copyright (c) 2019 Bill Peregoy

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
