import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :escape_disaster, EscapeDisaster.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "escape_disaster_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :escape_disaster, EscapeDisasterWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "vKWHB6QfSMrJe0e07m3qc3VeF50Htlu+ck4UTX/55/yy+5rZKR1SGeCXTAZsi2l5",
  server: false

# In test we don't send emails.
config :escape_disaster, EscapeDisaster.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
