defmodule GraphqlBuilder do
  @moduledoc """
  Module conatining business logic for buiilding GraphQL queries and mutations.
  """

  alias GraphqlBuilder.Query

  @type fields :: [atom | tuple]

  @spec query(Query.t()) :: String.t()
  def query(query) do
    build(query_keyword(), query)
  end

  @spec mutation(Query.t()) :: String.t()
  def mutation(query) do
    build(mutation_keyword(), query)
  end

  @spec subscription(Query.t()) :: String.t()
  def subscription(query) do
    build(subscription_keyword(), query)
  end

  @spec build(String.t(), Query.t()) :: String.t()
  defp build(type_keyword, %Query{operation: operation, fields: fields, variables: variables}) do
    indent_level = 2

    [
      type_keyword,
      operation_and_variables(operation, variables),
      query_fields(fields, indent_level + 2, newline: true),
      indented_closing_brace(indent_level),
      indented_closing_brace(indent_level - 2)
    ]
    |> Enum.join()
  end

  @spec query_keyword :: String.t()
  defp query_keyword do
    "query {\n"
  end

  @spec mutation_keyword :: String.t()
  defp mutation_keyword do
    "mutation {\n"
  end

  @spec subscription_keyword :: String.t()
  defp subscription_keyword do
    "subscription {\n"
  end

  @spec operation_and_variables(atom, [atom | tuple], keyword) :: String.t()
  defp operation_and_variables(operation, variables, opts \\ []) do
    indent_level = Keyword.get(opts, :indent_level, 2)

    indent(indent_level) <>
      "#{operation}" <>
      variable_list(variables) <>
      " {\n"
  end

  @spec indented_closing_brace(integer) :: String.t()
  defp indented_closing_brace(indent_level) do
    indent(indent_level) <> "}\n"
  end

  @spec query_fields(fields | {keyword, fields}, integer, keyword) :: String.t()
  defp query_fields(input, indent_level, opts \\ [])

  defp query_fields(fields, indent_level, opts) do
    {field_string, _} = Enum.reduce(fields, {"", indent_level}, &process_nested_field/2)
    String.trim_trailing(field_string, "\n") <> eol(opts)
  end

  @spec process_nested_field(atom, {String.t(), integer}) :: {String.t(), integer}
  defp process_nested_field(elem, {acc, indent_level}) when is_atom(elem) do
    {acc <> indent(indent_level) <> "#{elem}\n", indent_level}
  end

  # For variables with their own arguments.
  defp process_nested_field({label, {args, sub_fields}}, {acc, indent_level}) do
    acc =
      acc <>
        indent(indent_level) <>
        "#{label}#{variable_list(args)} {\n" <>
        query_fields(sub_fields, indent_level + 2) <>
        "\n" <> indent(indent_level) <> "}"

    {acc, indent_level}
  end

  defp process_nested_field({:on, on, sub_fields}, {acc, indent_level}) do
    acc =
      acc <>
        indent(indent_level) <>
        "... on #{on} {\n" <>
        query_fields(sub_fields, indent_level + 2) <>
        "\n" <> indent(indent_level) <> "}\n"

    {acc, indent_level}
  end

  defp process_nested_field({label, sub_fields}, {acc, indent_level}) do
    acc =
      acc <>
        indent(indent_level) <>
        "#{label} {\n" <>
        query_fields(sub_fields, indent_level + 2) <>
        "\n" <> indent(indent_level) <> "}"

    {acc, indent_level}
  end

  @spec variable_list(keyword | map | nil) :: String.t()
  defp variable_list(nil) do
    ""
  end

  defp variable_list(variables) do
    str = Enum.map_join(variables, ", ", &variable/1)
    "(#{str})"
  end

  @spec variable({atom, any}) :: String.t()
  defp variable({key, value}) do
    cond do
      is_binary(value) ->
        "#{key}: #{inspect(value)}"

      [] == value ->
        "#{key}: []"

      Keyword.keyword?(value) or is_map(value) ->
        list = sub_variable_list(value)
        "#{key}: #{list}"

      is_list(value) ->
        joined_values = Enum.map_join(value, ", ", &value/1)
        "#{key}: [#{joined_values}]"

      is_nil(value) ->
        "#{key}: null"

      true ->
        "#{key}: #{value}"
    end
  end

  @spec value(any) :: any
  defp value(val) when is_binary(val), do: inspect(val)
  defp value(val) when is_map(val), do: "{#{Enum.map_join(val, ", ", &variable/1)}}"

  defp value(val) do
    if Keyword.keyword?(val),
      do: "{#{Enum.map_join(val, ", ", &variable/1)}}",
      else: val
  end

  @spec sub_variable_list(map | [atom | tuple]) :: String.t()
  defp sub_variable_list(variables) do
    str = Enum.map_join(variables, ", ", &variable/1)
    "{#{str}}"
  end

  @spec indent(integer) :: String.t()
  defp indent(n) do
    String.duplicate(" ", n)
  end

  @spec eol(keyword) :: String.t()
  defp eol(opts) do
    if opts[:newline], do: "\n", else: ""
  end
end
