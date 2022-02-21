defmodule GraphqlBuilder.MixProject do
  use Mix.Project

  @source_url "https://github.com/billperegoy/graphql_builder"
  @version "0.3.0"

  def project do
    [
      app: :graphql_builder,
      version: @version,
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      docs: docs(),
      package: package(),
      preferred_cli_env: [
        ci: :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      ci: ["lint", "test", "dialyzer"],
      lint: [
        "compile --warnings-as-errors",
        "format --check-formatted",
        "credo --strict"
      ]
    ]
  end

  defp package do
    [
      description: "Tool to build GraphQL query strings from Elixir structs",
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: @version,
      formatters: ["html"]
    ]
  end
end
