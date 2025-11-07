#!/bin/bash

# Script específico para Arch Linux
# Instala MySQL (MariaDB) e Elixir

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Instalando dependências para Arch Linux...${NC}\n"

# Instalar MariaDB (MySQL compatível)
echo -e "${YELLOW}1. Instalando MariaDB...${NC}"
sudo pacman -S --noconfirm mariadb

# Inicializar MariaDB
echo -e "${YELLOW}2. Inicializando MariaDB...${NC}"
# Tentar comando novo primeiro, depois fallback para antigo
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql 2>/dev/null || \
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

# Iniciar e habilitar MariaDB
echo -e "${YELLOW}3. Iniciando MariaDB...${NC}"
sudo systemctl enable mariadb
sudo systemctl start mariadb

# Instalar Erlang e Elixir
echo -e "${YELLOW}4. Instalando Erlang e Elixir...${NC}"
sudo pacman -S --noconfirm erlang elixir

# Verificar instalações
echo -e "\n${GREEN}Verificando instalações...${NC}"
mysql --version && echo -e "${GREEN}✅ MariaDB instalado${NC}" || echo -e "${RED}❌ Erro MariaDB${NC}"
elixir --version && echo -e "${GREEN}✅ Elixir instalado${NC}" || echo -e "${RED}❌ Erro Elixir${NC}"
mix --version && echo -e "${GREEN}✅ Mix instalado${NC}" || echo -e "${RED}❌ Erro Mix${NC}"

echo -e "\n${GREEN}✅ Instalação concluída!${NC}"
echo -e "${YELLOW}Próximo passo: cd elixir-chat && mix deps.get${NC}"

