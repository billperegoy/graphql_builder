defmodule GraphqlBuilder do
  @moduledoc """
  Documentation for GraphqlBuilder.
  """

  def generate(%{operation: operation, fields: fields}) do
    fields_string = generate_fields_string(fields)

    """
    query {
      #{operation} {
        #{fields_string}
      }
    }
    """
  end

  def generate_fields_string(fields) do
    if Enum.all?(fields, &is_atom/1) do
      Enum.join(fields, ",\n    ")
    else
      Enum.reduce(fields, "", &process_nested_field/2)
    end
  end

  def process_nested_field(elem, acc) when is_atom(elem) do
    acc <> "#{elem},\n "
  end

  def process_nested_field({label, sub_fields}, acc) do
    acc <> "  #{label} {\n" <> generate_fields_string(sub_fields) <> "\n}"
  end
end
