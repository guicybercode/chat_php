#!/bin/bash

# Script para criar banco de dados
# Tenta com mysql normal, depois com sudo mysql (Arch Linux)

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}Criando banco de dados chat_online...${NC}"

# Tentar com mysql normal primeiro
if mysql -u root < database/schema.sql 2>/dev/null; then
    echo -e "${GREEN}✅ Banco criado com sucesso (mysql -u root)${NC}"
    exit 0
fi

# Se falhar, tentar com sudo mysql (Arch Linux)
if sudo mysql < database/schema.sql 2>/dev/null; then
    echo -e "${GREEN}✅ Banco criado com sucesso (sudo mysql)${NC}"
    exit 0
fi

# Se ainda falhar, tentar com senha vazia
if mysql -u root -p'' < database/schema.sql 2>/dev/null; then
    echo -e "${GREEN}✅ Banco criado com sucesso${NC}"
    exit 0
fi

echo -e "${RED}❌ Erro ao criar banco de dados${NC}"
echo -e "${YELLOW}Tente manualmente:${NC}"
echo "  sudo mysql < database/schema.sql"
echo "  ou"
echo "  mysql -u root -p < database/schema.sql"
exit 1

