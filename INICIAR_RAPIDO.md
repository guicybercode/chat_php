# 🚀 Iniciar Servidores Rápido

## Problema: Tela em Branco

Se você está vendo uma tela em branco, os servidores provavelmente não estão rodando!

## Solução Rápida

### Opção 1: Script Automático (Recomendado)

```bash
./start-dev.sh
```

Isso vai iniciar:
- ✅ PHP na porta 8000 (Frontend + API)
- ✅ Phoenix na porta 4000 (WebSocket)
- ✅ Python na porta 8080 (Frontend alternativo)

**Acesse:** http://localhost:8000 ou http://localhost:8080

### Opção 2: Manual (3 Terminais)

#### Terminal 1 - PHP (Frontend + API):
```bash
cd php-api
php -S localhost:8000 router.php
```

#### Terminal 2 - Phoenix:
```bash
cd elixir-chat
mix phx.server
```

#### Terminal 3 - Frontend Alternativo (opcional):
```bash
cd public
python3 -m http.server 8080
```

## Verificar se Está Rodando

```bash
./verificar-servidores.sh
```

Ou manualmente:
```bash
# Verificar portas
lsof -i :8000
lsof -i :4000
lsof -i :8080

# Testar URLs
curl http://localhost:8000
curl http://localhost:4000
curl http://localhost:8080
```

## URLs Corretas

- **Frontend Principal:** http://localhost:8000
- **Frontend Alternativo:** http://localhost:8080
- **API PHP:** http://localhost:8000/php-api/user.php
- **Phoenix WebSocket:** ws://localhost:4000/socket/websocket

## Problemas Comuns

### "Connection refused" ou tela em branco
→ Servidores não estão rodando. Execute `./start-dev.sh`

### "NoRouteError" no Phoenix
→ Normal! Phoenix só serve WebSocket, não precisa de rotas HTTP

### CSS/JS não carregam
→ Verifique se os arquivos existem em `public/css/` e `public/js/`

### Erro CORS
→ O JavaScript foi atualizado para usar `http://localhost:8000/php-api` em desenvolvimento

## Logs

Se algo não funcionar, veja os logs:

```bash
# PHP
tail -f /tmp/php-server.log

# Phoenix
tail -f /tmp/phoenix-server.log

# Frontend
tail -f /tmp/frontend-server.log
```

## Parar Servidores

Pressione `Ctrl+C` no terminal onde rodou `./start-dev.sh`

Ou mate os processos:
```bash
pkill -f "php -S"
pkill -f "mix phx.server"
pkill -f "python3 -m http.server"
```

