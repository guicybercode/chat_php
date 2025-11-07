defmodule ChatOnline.Repo do
  use Ecto.Repo,
    otp_app: :chat_online,
    adapter: Ecto.Adapters.MyXQL
end


