import Config

config :chat_online, ChatOnline.Repo,
  username: "root",
  password: "",
  hostname: "localhost",
  database: "chat_online_test",
  pool: Ecto.Adapters.SQL.Sandbox

config :chat_online, ChatOnlineWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn


