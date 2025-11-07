# 📦 Resumo de Instalação

## ✅ O que foi criado

1. **REQUISITOS.md** - Lista completa de dependências e requisitos
2. **ARQUIVOS_NECESSARIOS.md** - Lista de todos os arquivos do projeto
3. **instalar-dependencias.sh** - Script automático para instalar tudo
4. **verificar-instalacao.sh** - Script para verificar se está tudo OK

## 🚀 Como Instalar

### Opção 1: Script Automático (Recomendado)

```bash
# Executar script de instalação
./instalar-dependencias.sh
```

O script irá:
- Detectar sua distribuição Linux
- Instalar PHP, MySQL, Elixir automaticamente
- Instalar dependências do Phoenix
- Criar banco de dados
- Verificar tudo

### Opção 2: Manual

#### 1. Instalar dependências do sistema:

**Arch Linux:**
```bash
sudo pacman -S php php-mysql mysql erlang elixir python
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install php php-cli php-mysql mysql-server erlang elixir python3
```

**Fedora:**
```bash
sudo dnf install php php-cli php-mysqlnd mysql-server erlang elixir python3
```

#### 2. Instalar dependências do Phoenix:
```bash
cd elixir-chat
mix deps.get
mix compile
```

#### 3. Criar banco de dados:
```bash
mysql -u root -p < database/schema.sql
```

#### 4. Configurar credenciais:
- Edite `php-api/config.php`
- Edite `elixir-chat/config/dev.exs`

## 🔍 Verificar Instalação

Execute o script de verificação:

```bash
./verificar-instalacao.sh
```

Ou verifique manualmente:

```bash
# PHP
php -v
php -m | grep pdo_mysql

# MySQL
mysql --version
sudo systemctl status mysql

# Elixir
elixir --version
mix --version

# Dependências Phoenix
cd elixir-chat
mix deps.get
```

## 📋 Status Atual

Execute para ver o status:

```bash
./verificar-instalacao.sh
```

## ⚠️ O que falta instalar

Com base na verificação:

1. **MySQL** - Não encontrado
   ```bash
   # Arch
   sudo pacman -S mysql
   
   # Ubuntu/Debian
   sudo apt install mysql-server
   ```

2. **Elixir** - Não encontrado
   ```bash
   # Arch
   sudo pacman -S erlang elixir
   
   # Ubuntu/Debian
   sudo apt install erlang elixir
   ```

3. **Dependências Phoenix** - Precisa instalar após ter Elixir
   ```bash
   cd elixir-chat
   mix deps.get
   ```

## 📚 Documentação

- **REQUISITOS.md** - Detalhes completos de requisitos
- **ARQUIVOS_NECESSARIOS.md** - Lista de arquivos do projeto
- **COMO_RODAR.md** - Como rodar o servidor
- **INSTALL.md** - Guia de instalação produção

## 🎯 Próximos Passos

1. Instalar dependências: `./instalar-dependencias.sh`
2. Verificar: `./verificar-instalacao.sh`
3. Configurar credenciais MySQL
4. Rodar: `./start-dev.sh` ou seguir `COMO_RODAR.md`


