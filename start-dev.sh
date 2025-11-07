#!/bin/bash

# Script para iniciar servidores em modo desenvolvimento
# Uso: ./start-dev.sh

echo "🚀 Iniciando servidores do Chat Online..."

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar se MySQL/MariaDB está rodando
echo -e "${YELLOW}Verificando MySQL/MariaDB...${NC}"
# Tentar conectar com mysql normal, se falhar tentar com sudo mysql (Arch Linux)
if mysql -u root -e "SELECT 1" > /dev/null 2>&1 || \
   sudo mysql -u root -e "SELECT 1" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ MySQL/MariaDB OK${NC}"
else
    echo -e "${YELLOW}⚠️  MySQL não está rodando. Tentando iniciar...${NC}"
    # Tentar iniciar mysql ou mariadb
    if sudo systemctl start mysql 2>/dev/null || sudo systemctl start mariadb 2>/dev/null; then
        echo -e "${GREEN}✅ MySQL/MariaDB iniciado${NC}"
        sleep 2
        # Tentar conectar novamente
        if mysql -u root -e "SELECT 1" > /dev/null 2>&1 || \
           sudo mysql -u root -e "SELECT 1" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ MySQL/MariaDB OK${NC}"
        else
            echo -e "${YELLOW}⚠️  MySQL iniciado mas não consegue conectar${NC}"
            echo -e "${YELLOW}No Arch Linux, use: sudo mysql${NC}"
        fi
    else
        echo -e "${RED}❌ Não foi possível iniciar MySQL/MariaDB${NC}"
        echo "Tente manualmente:"
        echo "  sudo systemctl start mariadb  # Para Arch Linux"
        echo "  sudo systemctl start mysql    # Para Ubuntu/Debian"
        exit 1
    fi
fi

# Verificar se banco existe
# Tentar com mysql normal primeiro, depois com sudo mysql (para Arch Linux)
if mysql -u root -e "USE chat_online" > /dev/null 2>&1 || \
   sudo mysql -u root -e "USE chat_online" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Banco de dados existe${NC}"
else
    echo -e "${YELLOW}Criando banco de dados...${NC}"
    # Tentar criar com mysql normal, se falhar tentar com sudo
    if mysql -u root < database/schema.sql 2>/dev/null || \
       sudo mysql < database/schema.sql 2>/dev/null; then
        echo -e "${GREEN}✅ Banco de dados criado${NC}"
    else
        echo -e "${RED}❌ Erro ao criar banco de dados${NC}"
        echo -e "${YELLOW}Tente criar manualmente:${NC}"
        echo "  sudo mysql < database/schema.sql"
        echo "  ou"
        echo "  mysql -u root -p < database/schema.sql"
        exit 1
    fi
fi

# Verificar PHP
echo -e "${YELLOW}Verificando PHP...${NC}"
if ! command -v php &> /dev/null; then
    echo -e "${RED}❌ PHP não encontrado${NC}"
    exit 1
fi
echo -e "${GREEN}✅ PHP encontrado: $(php -v | head -n 1)${NC}"

# Verificar Elixir
echo -e "${YELLOW}Verificando Elixir...${NC}"
if ! command -v mix &> /dev/null; then
    echo -e "${RED}❌ Elixir/Mix não encontrado${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Elixir encontrado: $(elixir --version | head -n 1)${NC}"

# Verificar dependências Phoenix
echo -e "${YELLOW}Verificando dependências Phoenix...${NC}"
cd elixir-chat
if [ ! -d "deps" ]; then
    echo "Instalando dependências..."
    mix deps.get
    mix compile
fi
cd ..

# Verificar portas
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo -e "${RED}❌ Porta $1 já está em uso${NC}"
        return 1
    fi
    return 0
}

echo -e "${YELLOW}Verificando portas...${NC}"
check_port 8000 || exit 1
check_port 4000 || exit 1
check_port 8080 || exit 1
echo -e "${GREEN}✅ Portas disponíveis${NC}"

# Função para limpar processos ao sair
cleanup() {
    echo -e "\n${YELLOW}Parando servidores...${NC}"
    kill $PHP_PID $PHOENIX_PID $FRONTEND_PID 2>/dev/null
    exit
}

trap cleanup INT TERM

# Iniciar PHP (servindo frontend e API)
echo -e "\n${GREEN}Iniciando servidor PHP na porta 8000 (Frontend + API)...${NC}"
cd php-api
php -S localhost:8000 router.php > /tmp/php-server.log 2>&1 &
PHP_PID=$!
cd ..
sleep 2

# Iniciar Phoenix
echo -e "${GREEN}Iniciando servidor Phoenix na porta 4000...${NC}"
cd elixir-chat
mix phx.server > /tmp/phoenix-server.log 2>&1 &
PHOENIX_PID=$!
cd ..
sleep 3

# Iniciar Frontend
echo -e "${GREEN}Iniciando servidor frontend na porta 8080...${NC}"
cd public
python3 -m http.server 8080 > /tmp/frontend-server.log 2>&1 &
FRONTEND_PID=$!
cd ..

# Aguardar servidores iniciarem
sleep 2

echo -e "\n${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Servidores iniciados!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "PHP API:     ${GREEN}http://localhost:8000${NC}"
echo -e "Phoenix WS:  ${GREEN}http://localhost:4000${NC}"
echo -e "Frontend:    ${GREEN}http://localhost:8080${NC}"
echo -e "\n${YELLOW}Acesse: http://localhost:8080${NC}"
echo -e "\n${YELLOW}Pressione Ctrl+C para parar todos os servidores${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}\n"

# Manter script rodando
wait

