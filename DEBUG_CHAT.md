# 🐛 Debug do Chat

## Como Verificar se Está Funcionando

### 1. Abrir Console do Navegador

Pressione `F12` ou `Ctrl+Shift+I` e vá na aba **Console**.

### 2. Verificar Erros

Procure por mensagens em vermelho. Erros comuns:

- **"WebSocket connection failed"** → Phoenix não está rodando
- **"Failed to fetch"** → API PHP não está acessível
- **"CORS error"** → Problema de CORS (já corrigido)

### 3. Verificar Logs

No console, você deve ver:
- `Conectando ao WebSocket: ws://localhost:4000/socket/websocket`
- `WebSocket conectado`
- `Socket conectado, entrando no channel...`
- `✅ Entrou no chat!`

### 4. Testar Manualmente

#### Testar API PHP:
```bash
curl -X POST http://localhost:8000/php-api/user.php \
  -H "Content-Type: application/json" \
  -d '{"username":"teste"}'
```

Deve retornar: `{"success":true,"user":{...}}`

#### Testar Phoenix WebSocket:
```bash
# Verificar se está rodando
curl http://localhost:4000

# Ver logs
tail -f /tmp/phoenix-server.log
```

### 5. Verificar Servidores

```bash
./verificar-servidores.sh
```

## Problemas Comuns

### "Erro ao fazer login"
- Verifique se PHP está rodando na porta 8000
- Verifique se MySQL está rodando
- Veja logs: `tail -f /tmp/php-server.log`

### "Erro na conexão WebSocket"
- Verifique se Phoenix está rodando na porta 4000
- Veja logs: `tail -f /tmp/phoenix-server.log`
- Teste: `curl http://localhost:4000`

### Tela fica em branco após login
- Abra console do navegador (F12)
- Veja se há erros JavaScript
- Verifique se WebSocket conectou

### Mensagens não aparecem
- Verifique se channel está "joined"
- Veja console para erros
- Verifique se Phoenix está salvando no banco

## Comandos Úteis

```bash
# Ver todos os processos
ps aux | grep -E "(php|mix|python)" | grep -v grep

# Ver portas em uso
lsof -i :8000 -i :4000 -i :8080

# Matar todos os servidores
pkill -f "php -S"
pkill -f "mix phx.server"
pkill -f "python3 -m http.server"

# Reiniciar tudo
./start-dev.sh
```

