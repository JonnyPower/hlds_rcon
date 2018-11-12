defmodule HLDSRcon.MixProject do
  use Mix.Project

  def project do
    [
      app: :hlds_rcon,
      version: "1.0.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      description: description(),
      package: package(),
      name: "HLDSRcon",
      source_url: "https://github.com/JonnyPower/hlds_rcon",
      docs: [
        main: "HLDSRcon",
        extras: ["README.md"]
      ]
    ]
  end

  def description do
    "A elixir library for creating Half-Life Dedicated Server (a.k.a \"HLDS\") remote connections (a.k.a \"rcon\") and executing commands."
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {HLDSRcon.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT License"],
      links: %{
        "GitHub" => "https://github.com/JonnyPower/hlds_rcon"
      }
    ]
  end
end
