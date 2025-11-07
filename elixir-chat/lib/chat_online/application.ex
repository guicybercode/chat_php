defmodule ChatOnline.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ChatOnline.Repo,
      {Phoenix.PubSub, name: ChatOnline.PubSub},
      ChatOnlineWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: ChatOnline.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ChatOnlineWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end


