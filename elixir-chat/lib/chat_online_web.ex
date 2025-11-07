defmodule ChatOnlineWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use ChatOnlineWeb, :controller
      use ChatOnlineWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean. This
  could be done inside `use ChatOnlineWeb, :view`, but
  be careful: remember that the default view is not
  available during compilation.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: ChatOnlineWeb

      import Plug.Conn
      import ChatOnlineWeb.Gettext
      alias ChatOnlineWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import ChatOnlineWeb.Gettext
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end


