import Config

config :chat_online, ChatOnline.Repo,
  username: "chat_user",
  password: "chat123",
  hostname: "localhost",
  database: "chat_online"

config :chat_online, ChatOnlineWeb.Endpoint,
  code_reloader: true,
  check_origin: false,
  debug_errors: true,
  watchers: []


