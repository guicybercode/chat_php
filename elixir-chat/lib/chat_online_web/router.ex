defmodule ChatOnlineWeb.Router do
  use ChatOnlineWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChatOnlineWeb do
    pipe_through :api
    # Rotas vazias - toda comunicação via WebSocket
  end
end


