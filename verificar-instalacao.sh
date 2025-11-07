#!/bin/bash

# Script para verificar se tudo está instalado corretamente

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "🔍 Verificando instalação..."
echo ""

# Verificar PHP
echo -n "PHP: "
if command -v php &> /dev/null; then
    PHP_VER=$(php -v | head -n 1)
    if php -m | grep -q pdo_mysql; then
        echo -e "${GREEN}✅ $PHP_VER (pdo_mysql OK)${NC}"
    else
        echo -e "${YELLOW}⚠️  $PHP_VER (pdo_mysql faltando)${NC}"
    fi
else
    echo -e "${RED}❌ Não instalado${NC}"
fi

# Verificar MySQL
echo -n "MySQL: "
if command -v mysql &> /dev/null; then
    MYSQL_VER=$(mysql --version)
    echo -e "${GREEN}✅ $MYSQL_VER${NC}"
else
    echo -e "${RED}❌ Não instalado${NC}"
fi

# Verificar Elixir
echo -n "Elixir: "
if command -v elixir &> /dev/null; then
    ELIXIR_VER=$(elixir --version | head -n 1)
    echo -e "${GREEN}✅ $ELIXIR_VER${NC}"
else
    echo -e "${RED}❌ Não instalado${NC}"
fi

# Verificar Mix
echo -n "Mix: "
if command -v mix &> /dev/null; then
    MIX_VER=$(mix --version | head -n 1)
    echo -e "${GREEN}✅ $MIX_VER${NC}"
else
    echo -e "${RED}❌ Não instalado${NC}"
fi

# Verificar banco de dados
echo -n "Banco de dados: "
if mysql -u root -e "USE chat_online" 2>/dev/null || sudo mysql -e "USE chat_online" 2>/dev/null; then
    echo -e "${GREEN}✅ chat_online existe${NC}"
else
    echo -e "${YELLOW}⚠️  chat_online não existe (execute: mysql -u root -p < database/schema.sql)${NC}"
fi

# Verificar dependências Phoenix
echo -n "Dependências Phoenix: "
if [ -d "elixir-chat/deps" ]; then
    DEPS_COUNT=$(ls -1 elixir-chat/deps 2>/dev/null | wc -l)
    echo -e "${GREEN}✅ $DEPS_COUNT dependências instaladas${NC}"
else
    echo -e "${YELLOW}⚠️  Não instaladas (execute: cd elixir-chat && mix deps.get)${NC}"
fi

# Verificar arquivos obrigatórios
echo ""
echo "📁 Verificando arquivos obrigatórios:"

FILES=(
    "database/schema.sql"
    "php-api/config.php"
    "php-api/user.php"
    "php-api/messages.php"
    "elixir-chat/mix.exs"
    "elixir-chat/lib/chat_online_web/channels/chat_channel.ex"
    "public/index.html"
    "public/css/style.css"
    "public/js/chat.js"
)

MISSING=0
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}✅${NC} $file"
    else
        echo -e "  ${RED}❌${NC} $file"
        MISSING=$((MISSING + 1))
    fi
done

echo ""
if [ $MISSING -eq 0 ]; then
    echo -e "${GREEN}✅ Todos os arquivos obrigatórios estão presentes!${NC}"
else
    echo -e "${RED}❌ Faltam $MISSING arquivo(s) obrigatório(s)${NC}"
fi


