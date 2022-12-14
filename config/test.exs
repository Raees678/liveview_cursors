import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :liveview_cursors, LiveviewCursorsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "gQJzHHRS/9qJIn1FHKHCavU3gyQEap6Z/zNKoEnqyUz2kSpVh024VcFOeV9ALtDl",
  server: false

# In test we don't send emails.
config :liveview_cursors, LiveviewCursors.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
