defmodule ChatOnlineWeb.ChatChannel do
  use ChatOnlineWeb, :channel
  alias ChatOnline.Repo
  
  intercept ["new_message", "user_joined", "user_left"]

  @impl true
  def join("chat:lobby", payload, socket) do
    if authorized?(payload) do
      username = payload["username"]
      
      # Armazenar username no socket
      socket = assign(socket, :username, username)
      
      # Carregar histórico de mensagens
      messages = load_recent_messages()
      
      # Notificar outros usuários DEPOIS de retornar {:ok}
      # Usar send para enviar mensagem assíncrona
      send(self(), {:after_join, username})
      
      {:ok, %{messages: messages}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_info({:after_join, username}, socket) do
    # Agora podemos fazer broadcast porque o socket está joined
    broadcast(socket, "user_joined", %{
      username: username,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    })
    
    {:noreply, socket}
  end

  @impl true
  def handle_in("new_message", %{"username" => username, "message" => message}, socket) do
    # Salvar mensagem no banco
    save_message(username, message)
    
    # Broadcast para todos na sala
    broadcast(socket, "new_message", %{
      username: username,
      message: message,
      timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
    })
    
    {:noreply, socket}
  end

  @impl true
  def handle_out("new_message", payload, socket) do
    push(socket, "new_message", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_out("user_joined", payload, socket) do
    push(socket, "user_joined", payload)
    {:noreply, socket}
  end

  @impl true
  def handle_out("user_left", payload, socket) do
    push(socket, "user_left", payload)
    {:noreply, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    # Quando usuário desconecta, notificar outros
    if username = socket.assigns[:username] do
      broadcast_from(socket, "user_left", %{
        username: username,
        timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
      })
    end
    {:noreply, socket}
  end

  defp authorized?(payload) do
    username = payload["username"]
    is_binary(username) and String.length(username) >= 2 and String.length(username) <= 50
  end

  defp save_message(username, message) do
    # Inserir mensagem diretamente no MySQL
    query = """
    INSERT INTO messages (username, message, created_at)
    VALUES (?, ?, NOW())
    """
    
    case Ecto.Adapters.SQL.query(Repo, query, [username, message]) do
      {:ok, _} -> :ok
      {:error, error} -> 
        IO.inspect(error, label: "Erro ao salvar mensagem")
        :error
    end
  end

  defp load_recent_messages(limit \\ 50) do
    query = """
    SELECT id, username, message, created_at
    FROM messages
    ORDER BY created_at DESC
    LIMIT ?
    """
    
    case Ecto.Adapters.SQL.query(Repo, query, [limit]) do
      {:ok, %{rows: rows}} ->
        rows
        |> Enum.map(fn [id, username, message, created_at] ->
          %{
            id: id,
            username: username,
            message: message,
            created_at: format_datetime(created_at)
          }
        end)
        |> Enum.reverse()
      
      {:error, error} ->
        IO.inspect(error, label: "Erro ao carregar mensagens")
        []
    end
  end

  defp format_datetime(datetime) when is_binary(datetime), do: datetime
  defp format_datetime(%NaiveDateTime{} = dt), do: NaiveDateTime.to_iso8601(dt)
  defp format_datetime(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp format_datetime(other), do: to_string(other)
end

