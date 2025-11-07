#!/bin/bash

# Script para verificar e reiniciar Phoenix

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "🔍 Verificando Phoenix..."

# Verificar se está rodando
if ps aux | grep -E "mix.*phx|beam.*chat_online" | grep -v grep > /dev/null; then
    echo -e "${GREEN}✅ Phoenix está rodando${NC}"
else
    echo -e "${RED}❌ Phoenix NÃO está rodando${NC}"
    echo -e "${YELLOW}Iniciando Phoenix...${NC}"
    cd elixir-chat
    mix phx.server > /tmp/phoenix-server.log 2>&1 &
    sleep 3
    cd ..
fi

# Verificar porta
if lsof -Pi :4000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Porta 4000 está em uso${NC}"
else
    echo -e "${RED}❌ Porta 4000 NÃO está em uso${NC}"
fi

# Testar conexão
echo "Testando conexão..."
if curl -s http://localhost:4000 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Phoenix responde HTTP${NC}"
else
    echo -e "${RED}❌ Phoenix não responde HTTP${NC}"
fi

# Mostrar últimos logs
echo -e "\n${YELLOW}Últimas linhas do log:${NC}"
tail -10 /tmp/phoenix-server.log 2>/dev/null || echo "Log não encontrado"

