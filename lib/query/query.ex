defmodule GraphqlBuilder.Query do
  defstruct [
    :operation,
    :fields,
    :variables
  ]
end
