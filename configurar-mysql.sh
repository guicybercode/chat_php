#!/bin/bash

# Script para configurar MySQL/MariaDB para o chat

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Configurando MySQL/MariaDB para Chat Online...${NC}\n"

# Verificar se MySQL está rodando
if ! sudo systemctl is-active --quiet mariadb && ! sudo systemctl is-active --quiet mysql; then
    echo -e "${YELLOW}Iniciando MariaDB...${NC}"
    sudo systemctl start mariadb 2>/dev/null || sudo systemctl start mysql
fi

# Criar usuário e banco
echo -e "${YELLOW}Criando usuário e configurando permissões...${NC}"
sudo mysql << EOF
CREATE DATABASE IF NOT EXISTS chat_online CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'chat_user'@'localhost' IDENTIFIED BY 'chat123';
GRANT ALL PRIVILEGES ON chat_online.* TO 'chat_user'@'localhost';
FLUSH PRIVILEGES;
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Usuário e banco criados${NC}"
else
    echo -e "${RED}❌ Erro ao criar usuário${NC}"
    exit 1
fi

# Importar schema
echo -e "${YELLOW}Importando schema...${NC}"
mysql -u chat_user -pchat123 chat_online < database/schema.sql 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Schema importado${NC}"
else
    echo -e "${YELLOW}⚠️  Schema pode já estar importado ou erro ao importar${NC}"
fi

# Atualizar config.php
echo -e "${YELLOW}Atualizando php-api/config.php...${NC}"
sed -i "s/define('DB_USER', '.*');/define('DB_USER', 'chat_user');/" php-api/config.php
sed -i "s/define('DB_PASS', '.*');/define('DB_PASS', 'chat123');/" php-api/config.php
echo -e "${GREEN}✅ config.php atualizado${NC}"

# Atualizar dev.exs
echo -e "${YELLOW}Atualizando elixir-chat/config/dev.exs...${NC}"
sed -i 's/username: ".*",/username: "chat_user",/' elixir-chat/config/dev.exs
sed -i 's/password: ".*",/password: "chat123",/' elixir-chat/config/dev.exs
echo -e "${GREEN}✅ dev.exs atualizado${NC}"

# Testar conexão
echo -e "\n${YELLOW}Testando conexão...${NC}"
if mysql -u chat_user -pchat123 -e "USE chat_online; SELECT 1;" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Conexão MySQL OK${NC}"
else
    echo -e "${RED}❌ Erro na conexão${NC}"
    exit 1
fi

echo -e "\n${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Configuração concluída!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "\n${YELLOW}Credenciais configuradas:${NC}"
echo -e "Usuário: ${GREEN}chat_user${NC}"
echo -e "Senha: ${GREEN}chat123${NC}"
echo -e "Banco: ${GREEN}chat_online${NC}"
echo -e "\n${YELLOW}Agora você pode rodar: ./start-dev.sh${NC}\n"

