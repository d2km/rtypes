defmodule RTypes.MixProject do
  use Mix.Project

  def project do
    [
      app: :rtypes,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      description: "Automatically generate run time type checkers",
      package: [
        licenses: ["Apache 2.0"],
        links: %{"GitHub" => "https://github.com/d2km/rtypes"}
      ],
      name: "RTypes",
      source_url: "https://github.com/d2km/rtypes",
      deps: [{:ex_doc, ">= 0.0.0", only: :dev}]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end
end
