# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :soul_gut, SoulGut.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "soul_gut_repo",
  username: "postgres",
  password: "supersecure",
  hostname: "localhost"

config :soul_gut,
  ecto_repos: [SoulGut.Repo]

config :oauth2, debug: true


import_config "services.exs"
