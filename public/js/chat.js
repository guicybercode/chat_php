// Configuração
// Para desenvolvimento: API PHP na porta 8000, Frontend na 8080
const isDev = window.location.port === '8080' || window.location.hostname === 'localhost';
const API_BASE_URL = isDev 
    ? 'http://localhost:8000/php-api'  // Desenvolvimento
    : window.location.origin + '/php-api';  // Produção

// WebSocket Phoenix
const WS_PROTOCOL = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
const WS_HOST = window.location.hostname;
// Se estiver em produção (porta 80/443), use proxy Nginx, senão use porta 4000
const isProduction = window.location.port === '' || window.location.port === '80' || window.location.port === '443';
const WS_PATH = isProduction ? '/socket/websocket' : ':4000/socket/websocket';
const WS_URL = `${WS_PROTOCOL}//${WS_HOST}${WS_PATH}`;

// Estado da aplicação
let socket = null;
let channel = null;
let currentUsername = '';
let onlineUsers = new Set();

// Elementos DOM
const loginScreen = document.getElementById('login-screen');
const chatScreen = document.getElementById('chat-screen');
const loginForm = document.getElementById('login-form');
const usernameInput = document.getElementById('username-input');
const messageForm = document.getElementById('message-form');
const messageInput = document.getElementById('message-input');
const chatMessages = document.getElementById('chat-messages');
const currentUsernameSpan = document.getElementById('current-username');
const logoutBtn = document.getElementById('logout-btn');
const usersList = document.getElementById('users-list');

// Inicialização
document.addEventListener('DOMContentLoaded', () => {
    loginForm.addEventListener('submit', handleLogin);
    messageForm.addEventListener('submit', handleSendMessage);
    logoutBtn.addEventListener('click', handleLogout);
    
    // Verificar se já está logado (localStorage)
    const savedUsername = localStorage.getItem('chat_username');
    if (savedUsername) {
        usernameInput.value = savedUsername;
    }
});

// Handler de Login
async function handleLogin(e) {
    e.preventDefault();
    
    const username = usernameInput.value.trim();
    if (!username || username.length < 2 || username.length > 50) {
        alert('Por favor, digite um nome entre 2 e 50 caracteres!');
        return;
    }
    
    try {
        // Criar/validar usuário via API PHP
        const response = await fetch(`${API_BASE_URL}/user.php`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ username })
        });
        
        const data = await response.json();
        
        if (data.success) {
            currentUsername = username;
            localStorage.setItem('chat_username', username);
            
            // Conectar ao WebSocket
            connectToChat(username);
        } else {
            alert('Erro ao entrar: ' + (data.error || 'Erro desconhecido'));
        }
    } catch (error) {
        console.error('Erro ao fazer login:', error);
        alert('Erro ao conectar. Verifique se o servidor está rodando.');
    }
}

// Conectar ao WebSocket Phoenix
function connectToChat(username) {
    console.log('Conectando ao WebSocket:', WS_URL);
    
    // Criar socket
    socket = new Phoenix.Socket(WS_URL, {
        params: {},
        logger: (kind, msg, data) => {
            console.log(`Phoenix ${kind}: ${msg}`, data);
        }
    });
    
    // Configurar callbacks antes de conectar
    socket.onError((error) => {
        console.error("Erro no socket:", error);
        alert('Erro na conexão WebSocket. Verifique se o servidor Phoenix está rodando na porta 4000.');
    });
    
    socket.onClose(() => {
        console.log("Socket fechado");
    });
    
    // Conectar
    socket.connect();
    
    // Quando socket conectar, entrar no channel
    socket.onOpen(() => {
        console.log('Socket conectado, entrando no channel...');
        channel = socket.channel("chat:lobby", { username: username });
        
        // Eventos do channel
        channel.on("new_message", handleNewMessage);
        channel.on("user_joined", handleUserJoined);
        channel.on("user_left", handleUserLeft);
        
        // Entrar no channel
        const joinRequest = channel.join();
        
        joinRequest.receive("ok", (resp) => {
            console.log("✅ Entrou no chat!", resp);
            
            // Carregar histórico de mensagens
            if (resp && resp.messages && resp.messages.length > 0) {
                resp.messages.forEach(msg => {
                    displayMessage(msg.username, msg.message, msg.created_at);
                });
            }
            
            // Mostrar interface do chat
            loginScreen.style.display = 'none';
            chatScreen.style.display = 'flex';
            currentUsernameSpan.textContent = username;
            messageInput.focus();
            
            // Adicionar usuário atual à lista
            onlineUsers.add(username);
            updateUsersList();
            
            // Mostrar mensagem de boas-vindas
            displaySystemMessage(`Bem-vindo ao chat, ${username}! ^_^`);
        });
        
        joinRequest.receive("error", (resp) => {
            console.error("❌ Erro ao entrar no chat:", resp);
            const errorMsg = resp && resp.error ? resp.error : (resp && resp.reason ? resp.reason : JSON.stringify(resp));
            alert('Erro ao entrar no chat: ' + errorMsg);
            // Voltar para tela de login
            loginScreen.style.display = 'flex';
            chatScreen.style.display = 'none';
        });
        
        // Timeout para join
        setTimeout(() => {
            if (channel && channel.state !== 'joined') {
                console.error('Timeout ao entrar no channel. Estado:', channel.state);
                alert('Timeout ao conectar ao chat. Verifique se o Phoenix está rodando.');
            }
        }, 10000);
    });
}

// Handler de envio de mensagem
function handleSendMessage(e) {
    e.preventDefault();
    
    const message = messageInput.value.trim();
    if (!message) return;
    
    // Verificar se channel existe e está conectado
    if (!channel) {
        console.error('Channel não existe');
        alert('Erro: Channel não foi criado. Recarregue a página.');
        return;
    }
    
    if (channel.state !== 'joined') {
        console.error('Channel não está conectado. Estado:', channel.state);
        console.log('Tentando reconectar...');
        // Tentar reconectar
        connectToChat(currentUsername);
        setTimeout(() => {
            if (channel && channel.state === 'joined') {
                channel.push("new_message", {
                    username: currentUsername,
                    message: message
                });
                messageInput.value = '';
                messageInput.focus();
            } else {
                alert('Não foi possível conectar. Verifique se o Phoenix está rodando na porta 4000.');
            }
        }, 2000);
        return;
    }
    
    // Enviar mensagem
    channel.push("new_message", {
        username: currentUsername,
        message: message
    });
    
    messageInput.value = '';
    messageInput.focus();
}

// Handler de nova mensagem recebida
function handleNewMessage(payload) {
    displayMessage(payload.username, payload.message, payload.timestamp);
}

// Handler de usuário entrando
function handleUserJoined(payload) {
    if (payload.username !== currentUsername) {
        onlineUsers.add(payload.username);
        updateUsersList();
        displaySystemMessage(`${payload.username} entrou na sala! ^_^`);
    }
}

// Handler de usuário saindo
function handleUserLeft(payload) {
    if (payload.username !== currentUsername) {
        onlineUsers.delete(payload.username);
        updateUsersList();
        displaySystemMessage(`${payload.username} saiu da sala. :(`);
    }
}

// Exibir mensagem na tela
function displayMessage(username, message, timestamp) {
    const messageDiv = document.createElement('div');
    messageDiv.className = 'message';
    
    const time = timestamp ? formatTime(timestamp) : formatTime(new Date().toISOString());
    
    messageDiv.innerHTML = `
        <div class="message-header">
            <span class="message-username">${escapeHtml(username)}</span>
            <span class="message-time">${time}</span>
        </div>
        <div class="message-text">${escapeHtml(message)}</div>
    `;
    
    chatMessages.appendChild(messageDiv);
    chatMessages.scrollTop = chatMessages.scrollHeight;
}

// Exibir mensagem do sistema
function displaySystemMessage(message) {
    const messageDiv = document.createElement('div');
    messageDiv.className = 'message system-message';
    messageDiv.textContent = message;
    
    chatMessages.appendChild(messageDiv);
    chatMessages.scrollTop = chatMessages.scrollHeight;
}

// Atualizar lista de usuários online
function updateUsersList() {
    usersList.innerHTML = '';
    
    if (onlineUsers.size === 0) {
        const emptyDiv = document.createElement('div');
        emptyDiv.textContent = 'Ninguém online';
        emptyDiv.style.color = '#999';
        emptyDiv.style.fontStyle = 'italic';
        usersList.appendChild(emptyDiv);
        return;
    }
    
    onlineUsers.forEach(username => {
        const userDiv = document.createElement('div');
        userDiv.className = 'user-item';
        userDiv.textContent = username;
        usersList.appendChild(userDiv);
    });
}

// Handler de logout
function handleLogout() {
    if (channel) {
        channel.leave();
    }
    if (socket) {
        socket.disconnect();
    }
    
    localStorage.removeItem('chat_username');
    currentUsername = '';
    onlineUsers.clear();
    
    chatScreen.style.display = 'none';
    loginScreen.style.display = 'flex';
    usernameInput.value = '';
    chatMessages.innerHTML = '';
    usersList.innerHTML = '';
}

// Utilitários
function formatTime(timestamp) {
    const date = new Date(timestamp);
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    return `${hours}:${minutes}`;
}

function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Biblioteca Phoenix Socket (simplificada mas funcional)
if (typeof Phoenix === 'undefined') {
    window.Phoenix = {
        Socket: class {
            constructor(url, opts = {}) {
                this.endPoint = url;
                this.opts = opts;
                this.conn = null;
                this.channels = [];
                this.stateChangeCallbacks = { open: [], close: [], error: [], message: [] };
                this.vsn = "2.0.0";
                this.heartbeatInterval = null;
            }
            
            connect() {
                // Adicionar vsn à URL
                const separator = this.endPoint.includes('?') ? '&' : '?';
                const urlWithVsn = `${this.endPoint}${separator}vsn=${this.vsn}`;
                
                this.conn = new WebSocket(urlWithVsn);
                
                this.conn.onopen = () => {
                    console.log('WebSocket conectado');
                    this.stateChangeCallbacks.open.forEach(cb => cb());
                    this.startHeartbeat();
                };
                
                this.conn.onclose = () => {
                    console.log('WebSocket fechado');
                    this.stopHeartbeat();
                    this.stateChangeCallbacks.close.forEach(cb => cb());
                };
                
                this.conn.onerror = (error) => {
                    console.error('Erro WebSocket:', error);
                    this.stateChangeCallbacks.error.forEach(cb => cb(error));
                };
                
                this.conn.onmessage = (event) => {
                    try {
                        const data = JSON.parse(event.data);
                        const [joinRef, ref, topic, eventName, payload] = data;
                        
                        console.log('WebSocket message:', { joinRef, ref, topic, eventName, payload });
                        
                        // Processar heartbeat
                        if (eventName === 'phx_reply' && ref === null && topic === 'phoenix') {
                            console.log('Heartbeat recebido');
                            return; // Heartbeat reply
                        }
                        
                        // Processar mensagens dos channels
                        let handled = false;
                        this.channels.forEach(ch => {
                            if (ch.topic === topic) {
                                ch.handleMessage(joinRef, ref, eventName, payload);
                                handled = true;
                            }
                        });
                        
                        if (!handled && topic !== 'phoenix') {
                            console.warn('Mensagem não processada - nenhum channel encontrado para topic:', topic);
                        }
                    } catch (e) {
                        console.error('Erro ao processar mensagem:', e, event.data);
                    }
                };
            }
            
            startHeartbeat() {
                this.heartbeatInterval = setInterval(() => {
                    if (this.conn && this.conn.readyState === WebSocket.OPEN) {
                        const heartbeat = [null, null, "phoenix", "heartbeat", {}];
                        this.conn.send(JSON.stringify(heartbeat));
                    }
                }, 30000); // 30 segundos
            }
            
            stopHeartbeat() {
                if (this.heartbeatInterval) {
                    clearInterval(this.heartbeatInterval);
                    this.heartbeatInterval = null;
                }
            }
            
            onOpen(callback) {
                this.stateChangeCallbacks.open.push(callback);
            }
            
            onError(callback) {
                this.stateChangeCallbacks.error.push(callback);
            }
            
            onClose(callback) {
                this.stateChangeCallbacks.close.push(callback);
            }
            
            channel(topic, params = {}) {
                const chan = new Channel(topic, params, this);
                this.channels.push(chan);
                return chan;
            }
            
            disconnect() {
                this.stopHeartbeat();
                if (this.conn) {
                    this.conn.close();
                }
            }
        }
    };
    
    class Channel {
        constructor(topic, params, socket) {
            this.topic = topic;
            this.params = params;
            this.socket = socket;
            this.state = 'closed';
            this.joinRef = this.makeRef();
            this.bindings = [];
            this.pendingReplies = new Map();
        }
        
        makeRef() {
            return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
        }
        
        join() {
            if (this.socket.conn && this.socket.conn.readyState === WebSocket.OPEN) {
                this.state = 'joining';
                this.sendJoin();
            } else {
                // Aguardar conexão
                this.socket.onOpen(() => {
                    this.state = 'joining';
                    this.sendJoin();
                });
            }
            
            return {
                receive: (status, callback) => {
                    if (status === 'ok') {
                        this.bindings.push({ 
                            event: 'phx_reply', 
                            ref: this.joinRef,
                            callback: (payload) => {
                                if (payload && payload.status === 'ok') {
                                    this.state = 'joined';
                                    callback(payload.response || {});
                                } else if (payload && payload.status === 'error') {
                                    this.state = 'errored';
                                    callback({ error: payload.response });
                                }
                            }
                        });
                    } else if (status === 'error') {
                        this.bindings.push({ 
                            event: 'phx_reply', 
                            ref: this.joinRef,
                            callback: (payload) => {
                                if (payload && payload.status === 'error') {
                                    this.state = 'errored';
                                    callback(payload);
                                }
                            }
                        });
                    }
                    return this;
                }
            };
        }
        
        sendJoin() {
            const ref = this.makeRef();
            const message = [this.joinRef, ref, this.topic, 'phx_join', this.params];
            this.socket.conn.send(JSON.stringify(message));
        }
        
        on(event, callback) {
            this.bindings.push({ event, callback });
        }
        
        push(event, payload) {
            if (this.state !== 'joined') {
                console.warn('Channel não está conectado');
                return;
            }
            const ref = this.makeRef();
            const message = [this.joinRef, ref, this.topic, event, payload];
            this.socket.conn.send(JSON.stringify(message));
        }
        
        leave() {
            this.state = 'leaving';
            const ref = this.makeRef();
            const message = [this.joinRef, ref, this.topic, 'phx_leave', {}];
            this.socket.conn.send(JSON.stringify(message));
        }
        
        handleMessage(joinRef, ref, eventName, payload) {
            console.log('Channel message:', { joinRef, ref, eventName, payload, topic: this.topic });
            
            // Processar phx_reply
            if (eventName === 'phx_reply') {
                const matchingBindings = this.bindings.filter(b => 
                    b.event === 'phx_reply' && 
                    (b.ref === ref || b.ref === this.joinRef || !b.ref)
                );
                
                if (matchingBindings.length === 0) {
                    console.warn('Nenhum binding encontrado para phx_reply', { ref, joinRef });
                }
                
                matchingBindings.forEach(b => {
                    try {
                        b.callback(payload);
                    } catch (e) {
                        console.error('Erro ao executar callback:', e);
                    }
                });
            } else {
                // Processar outros eventos
                const matchingBindings = this.bindings.filter(b => b.event === eventName);
                
                if (matchingBindings.length === 0) {
                    console.warn('Nenhum binding encontrado para evento:', eventName);
                }
                
                matchingBindings.forEach(b => {
                    try {
                        b.callback(payload);
                    } catch (e) {
                        console.error('Erro ao executar callback:', e);
                    }
                });
            }
        }
    }
}

