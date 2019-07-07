defmodule GraphqlBuilder.Query do
  @type t :: %__MODULE__{
          operation: atom,
          fields: [atom],
          variables: [atom]
        }

  defstruct [
    :operation,
    :fields,
    :variables
  ]
end
