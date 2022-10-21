use Mix.Config

config :appsignal, :config,
  otp_app: :liveview_cursors,
  name: "liveview_cursors",
  push_api_key: System.get_env("APPSIGNAL_PUSH_API_KEY"),
  env: Mix.env()
