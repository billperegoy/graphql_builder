defmodule GraphqlBuilder.Query do
  @moduledoc """
  Data structure used to represent the data used to generate query or mutation data.
  """

  @type t :: %__MODULE__{
          operation: atom,
          fields: [atom | tuple],
          variables: [atom | tuple]
        }

  defstruct [
    :operation,
    :fields,
    :variables
  ]
end
