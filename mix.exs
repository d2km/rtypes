defmodule RTypes.MixProject do
  use Mix.Project

  def project do
    [
      app: :rtypes,
      version: "0.3.2",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      description: "Automatically generate run time type checkers",
      package: [
        licenses: ["Apache 2.0"],
        links: %{"GitHub" => "https://github.com/d2km/rtypes"}
      ],
      name: "RTypes",
      source_url: "https://github.com/d2km/rtypes",
      elixirc_paths: elixirc_paths(Mix.env()),
      erlc_paths: erlc_paths(Mix.env()),
      deps: [
        {:ex_doc, ">= 0.0.0", only: :dev},
        {:recon, "~> 2.5", only: :dev},
        {:benchee, "~> 1.0", only: :bench},
        {:stream_data, "~> 0.5"}
      ]
    ]
  end

  def elixirc_paths(:prod) do
    ["lib"]
  end

  def elixirc_paths(:dev) do
    ["lib"]
  end

  def elixirc_paths(:test) do
    ["lib", "test/lib", "bench/lib"]
  end

  def elixirc_paths(:bench) do
    ["lib", "bench/lib"]
  end

  def erlc_paths(:test) do
    ["src"]
  end

  def erlc_paths(_) do
    []
  end

  def application do
    [extra_applications: [:logger]]
  end
end
