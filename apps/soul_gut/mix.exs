defmodule SoulGut.Mixfile do
  use Mix.Project

  def project do
    [app: :soul_gut,
     version: "0.0.1",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {SoulGut, []},
     applications: [:logger, :oauth2, :timex]]
  end

  defp deps do
    [{:oauth2, "~> 0.8"},
     {:poison, "~> 2.0"},
     {:timex, "~> 3.0"}
    ]
  end
end
