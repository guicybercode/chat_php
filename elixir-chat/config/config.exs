import Config

config :chat_online, ChatOnline.Repo,
  username: "root",
  password: "",
  hostname: "localhost",
  database: "chat_online",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :chat_online, ChatOnlineWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  secret_key_base: "your-secret-key-base-change-in-production-use-mix-phx-gen-secret",
  render_errors: [
    formats: [json: ChatOnlineWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ChatOnline.PubSub,
  live_view: [signing_salt: "your-signing-salt"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"


