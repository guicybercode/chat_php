import Config

config :chat_online, ChatOnline.Repo,
  username: System.get_env("DB_USER", "root"),
  password: System.get_env("DB_PASS", ""),
  hostname: System.get_env("DB_HOST", "localhost"),
  database: System.get_env("DB_NAME", "chat_online"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

config :chat_online, ChatOnlineWeb.Endpoint,
  http: [
    ip: {0, 0, 0, 0},
    port: String.to_integer(System.get_env("PORT") || "4000")
  ],
  secret_key_base: System.get_env("SECRET_KEY_BASE") || "change-me-in-production",
  check_origin: false

config :logger, level: :info


