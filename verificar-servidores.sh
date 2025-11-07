#!/bin/bash

# Script para verificar se os servidores estão rodando

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "🔍 Verificando servidores..."
echo ""

# Verificar porta 8000 (PHP)
echo -n "Porta 8000 (PHP API): "
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Rodando${NC}"
    curl -s http://localhost:8000/php-api/user.php > /dev/null 2>&1 && \
        echo "  ${GREEN}✅ API respondendo${NC}" || \
        echo "  ${YELLOW}⚠️  API não responde${NC}"
else
    echo -e "${RED}❌ Não está rodando${NC}"
fi

# Verificar porta 4000 (Phoenix)
echo -n "Porta 4000 (Phoenix): "
if lsof -Pi :4000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Rodando${NC}"
    curl -s http://localhost:4000 > /dev/null 2>&1 && \
        echo "  ${GREEN}✅ Phoenix respondendo${NC}" || \
        echo "  ${YELLOW}⚠️  Phoenix não responde${NC}"
else
    echo -e "${RED}❌ Não está rodando${NC}"
fi

# Verificar porta 8080 (Frontend)
echo -n "Porta 8080 (Frontend): "
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Rodando${NC}"
    curl -s http://localhost:8080 > /dev/null 2>&1 && \
        echo "  ${GREEN}✅ Frontend respondendo${NC}" || \
        echo "  ${YELLOW}⚠️  Frontend não responde${NC}"
else
    echo -e "${RED}❌ Não está rodando${NC}"
fi

echo ""
echo "Para iniciar os servidores, execute:"
echo "  ./start-dev.sh"

