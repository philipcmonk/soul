use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or you later on).
config :soul_web, SoulWeb.Endpoint,
  secret_key_base: "ouuzkgTNLu8VDGhXu26+AJZJ6KaA+UWVE+loHlvgXVpF7x6Pnbz+hz3mgmC/Ytnp"

# Configure your database
config :soul_web, SoulWeb.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "soul_prod",
  pool_size: 20
