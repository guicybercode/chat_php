#!/bin/bash

# Script para instalar todas as dependências necessárias
# Uso: ./instalar-dependencias.sh

set -e

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Instalador de Dependências - Chat Online${NC}"
echo -e "${BLUE}════════════════════════════════════════════${NC}\n"

# Detectar distribuição Linux
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo $ID
    elif [ -f /etc/arch-release ]; then
        echo "arch"
    else
        echo "unknown"
    fi
}

DISTRO=$(detect_distro)
echo -e "${YELLOW}Distribuição detectada: $DISTRO${NC}\n"

# Verificar se é root
check_root() {
    if [ "$EUID" -eq 0 ]; then 
        echo -e "${RED}❌ Não execute este script como root/sudo${NC}"
        echo "O script pedirá senha quando necessário"
        exit 1
    fi
}

check_root

# Função para instalar pacotes
install_packages() {
    case $DISTRO in
        ubuntu|debian)
            echo -e "${YELLOW}Instalando pacotes via apt...${NC}"
            sudo apt update
            sudo apt install -y \
                php php-cli php-mysql php-json \
                mysql-server mysql-client \
                erlang elixir \
                python3 \
                git curl
            ;;
        arch|manjaro)
            echo -e "${YELLOW}Instalando pacotes via pacman...${NC}"
            # PHP já está instalado, verificar extensões
            if ! php -m | grep -q pdo_mysql; then
                echo -e "${YELLOW}Instalando extensão MySQL para PHP...${NC}"
                # No Arch, a extensão MySQL pode estar em php-sqlite ou precisa ser habilitada
                # Verificar se precisa instalar algo específico
                sudo pacman -S --noconfirm php
            fi
            
            # MySQL - usar mariadb por padrão
            if ! command -v mysql &> /dev/null; then
                echo -e "${YELLOW}Instalando MariaDB (MySQL compatível)...${NC}"
                sudo pacman -S --noconfirm mariadb
                echo -e "${YELLOW}Inicializando MariaDB...${NC}"
                sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
                sudo systemctl enable mariadb
                sudo systemctl start mariadb
            fi
            
            # Erlang e Elixir
            if ! command -v elixir &> /dev/null; then
                sudo pacman -S --noconfirm erlang elixir
            fi
            
            # Python e outras ferramentas
            sudo pacman -S --noconfirm python git curl
            ;;
        fedora|rhel|centos)
            echo -e "${YELLOW}Instalando pacotes via dnf...${NC}"
            sudo dnf install -y \
                php php-cli php-mysqlnd php-json \
                mysql-server mysql \
                erlang elixir \
                python3 \
                git curl
            ;;
        *)
            echo -e "${RED}❌ Distribuição não suportada automaticamente${NC}"
            echo "Por favor, instale manualmente:"
            echo "  - PHP 8.0+ com extensões pdo, pdo_mysql, json"
            echo "  - MySQL 8.0+"
            echo "  - Erlang/OTP 25+ e Elixir 1.15+"
            exit 1
            ;;
    esac
}

# Verificar PHP
check_php() {
    if command -v php &> /dev/null; then
        PHP_VERSION=$(php -v | head -n 1)
        echo -e "${GREEN}✅ PHP encontrado: $PHP_VERSION${NC}"
        
        # Verificar extensões
        if php -m | grep -q pdo_mysql; then
            echo -e "${GREEN}✅ Extensão pdo_mysql OK${NC}"
        else
            echo -e "${YELLOW}⚠️  Extensão pdo_mysql não encontrada${NC}"
            case $DISTRO in
                ubuntu|debian)
                    sudo apt install -y php-mysql
                    ;;
                arch|manjaro)
                    echo -e "${YELLOW}No Arch, pdo_mysql geralmente vem com php${NC}"
                    echo -e "${YELLOW}Verificando se precisa habilitar extensão...${NC}"
                    # No Arch, pode precisar editar php.ini ou instalar pacote específico
                    if [ -f /etc/php/php.ini ]; then
                        sudo sed -i 's/;extension=pdo_mysql/extension=pdo_mysql/' /etc/php/php.ini
                    fi
                    # Tentar instalar se houver pacote disponível
                    sudo pacman -S --noconfirm php 2>/dev/null || true
                    ;;
                fedora|rhel|centos)
                    sudo dnf install -y php-mysqlnd
                    ;;
            esac
        fi
        
        if php -m | grep -q json; then
            echo -e "${GREEN}✅ Extensão json OK${NC}"
        else
            echo -e "${YELLOW}⚠️  Extensão json não encontrada (geralmente já vem com PHP)${NC}"
        fi
    else
        echo -e "${RED}❌ PHP não encontrado${NC}"
        install_packages
    fi
}

# Verificar MySQL
check_mysql() {
    if command -v mysql &> /dev/null; then
        MYSQL_VERSION=$(mysql --version)
        echo -e "${GREEN}✅ MySQL encontrado: $MYSQL_VERSION${NC}"
        
        # Verificar se MySQL/MariaDB está rodando
        if sudo systemctl is-active --quiet mysql 2>/dev/null || \
           sudo systemctl is-active --quiet mariadb 2>/dev/null; then
            echo -e "${GREEN}✅ MySQL/MariaDB está rodando${NC}"
        else
            echo -e "${YELLOW}⚠️  MySQL/MariaDB não está rodando. Iniciando...${NC}"
            if sudo systemctl start mysql 2>/dev/null; then
                sudo systemctl enable mysql 2>/dev/null
            elif sudo systemctl start mariadb 2>/dev/null; then
                sudo systemctl enable mariadb 2>/dev/null
            else
                echo -e "${RED}❌ Não foi possível iniciar MySQL/MariaDB${NC}"
                echo "Tente manualmente: sudo systemctl start mariadb"
            fi
        fi
    else
        echo -e "${RED}❌ MySQL não encontrado${NC}"
        install_packages
        echo -e "${YELLOW}Configurando MySQL...${NC}"
        sudo systemctl start mysql 2>/dev/null || sudo systemctl start mariadb
        sudo systemctl enable mysql 2>/dev/null || sudo systemctl enable mariadb
    fi
}

# Verificar Elixir
check_elixir() {
    if command -v elixir &> /dev/null && command -v mix &> /dev/null; then
        ELIXIR_VERSION=$(elixir --version | head -n 1)
        MIX_VERSION=$(mix --version | head -n 1)
        echo -e "${GREEN}✅ Elixir encontrado: $ELIXIR_VERSION${NC}"
        echo -e "${GREEN}✅ Mix encontrado: $MIX_VERSION${NC}"
    else
        echo -e "${RED}❌ Elixir/Mix não encontrado${NC}"
        install_packages
        
        # Verificar novamente
        if ! command -v elixir &> /dev/null; then
            echo -e "${RED}❌ Erro ao instalar Elixir${NC}"
            echo "Tente instalar manualmente ou use asdf:"
            echo "  git clone https://github.com/asdf-vm/asdf.git ~/.asdf"
            echo "  asdf plugin add erlang"
            echo "  asdf plugin add elixir"
            echo "  asdf install erlang 25.3"
            echo "  asdf install elixir 1.15.0"
            exit 1
        fi
    fi
}

# Verificar Python
check_python() {
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version)
        echo -e "${GREEN}✅ Python encontrado: $PYTHON_VERSION${NC}"
    else
        echo -e "${YELLOW}⚠️  Python3 não encontrado (opcional, mas recomendado)${NC}"
        install_packages
    fi
}

# Instalar dependências do Phoenix
install_phoenix_deps() {
    if [ -d "elixir-chat" ]; then
        echo -e "\n${YELLOW}Instalando dependências do Phoenix...${NC}"
        cd elixir-chat
        
        if [ ! -d "deps" ]; then
            echo "Baixando dependências..."
            mix deps.get
        fi
        
        echo "Compilando projeto..."
        mix compile
        
        cd ..
        echo -e "${GREEN}✅ Dependências Phoenix instaladas${NC}"
    else
        echo -e "${RED}❌ Diretório elixir-chat não encontrado${NC}"
    fi
}

# Criar banco de dados
setup_database() {
    echo -e "\n${YELLOW}Configurando banco de dados...${NC}"
    
    if [ -f "database/schema.sql" ]; then
        echo "Criando banco de dados chat_online..."
        
        # Tentar criar banco (pode falhar se já existir, mas não é problema)
        mysql -u root -e "CREATE DATABASE IF NOT EXISTS chat_online CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || \
        sudo mysql -e "CREATE DATABASE IF NOT EXISTS chat_online CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || \
        echo -e "${YELLOW}⚠️  Não foi possível criar banco automaticamente. Crie manualmente:${NC}"
        echo "  mysql -u root -p < database/schema.sql"
        
        # Tentar importar schema
        if mysql -u root chat_online -e "SHOW TABLES;" 2>/dev/null | grep -q "users"; then
            echo -e "${GREEN}✅ Banco de dados já existe e tem tabelas${NC}"
        else
            echo "Importando schema..."
            mysql -u root chat_online < database/schema.sql 2>/dev/null || \
            sudo mysql chat_online < database/schema.sql 2>/dev/null || \
            echo -e "${YELLOW}⚠️  Não foi possível importar schema automaticamente${NC}"
            echo "Execute manualmente: mysql -u root -p chat_online < database/schema.sql"
        fi
    else
        echo -e "${RED}❌ Arquivo database/schema.sql não encontrado${NC}"
    fi
}

# Main
echo -e "${BLUE}Verificando dependências...${NC}\n"

check_php
echo ""
check_mysql
echo ""
check_elixir
echo ""
check_python
echo ""

install_phoenix_deps
echo ""
setup_database

echo -e "\n${GREEN}════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Instalação concluída!${NC}"
echo -e "${GREEN}════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}Próximos passos:${NC}"
echo "1. Configure as credenciais do MySQL em:"
echo "   - php-api/config.php"
echo "   - elixir-chat/config/dev.exs"
echo ""
echo "2. Execute o servidor:"
echo "   ./start-dev.sh"
echo "   ou siga as instruções em COMO_RODAR.md"
echo ""

