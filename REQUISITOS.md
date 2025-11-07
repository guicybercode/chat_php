# 📋 Requisitos e Dependências

## Requisitos do Sistema

### Obrigatórios

1. **PHP 8.0 ou superior**
   - Extensões necessárias: `pdo`, `pdo_mysql`, `json`
   - Verificar: `php -v`
   - Instalar: `sudo apt install php php-cli php-mysql`

2. **MySQL 8.0 ou superior** (ou MariaDB 10.3+)
   - Verificar: `mysql --version`
   - Instalar: `sudo apt install mysql-server`

3. **Elixir 1.15+ e Erlang/OTP 25+**
   - Verificar: `elixir --version` e `erl -version`
   - Instalar: `sudo apt install erlang elixir`
   - Ou via asdf: `asdf install erlang 25.3 && asdf install elixir 1.15.0`

4. **Mix** (vem com Elixir)
   - Verificar: `mix --version`

### Opcionais (para desenvolvimento)

5. **Python 3** (para servidor HTTP simples)
   - Verificar: `python3 --version`
   - Geralmente já vem instalado no Linux

6. **Node.js** (opcional, para alguns assets do Phoenix)
   - Verificar: `node --version`
   - Instalar: `sudo apt install nodejs npm`

7. **Git** (para clonar/baixar o projeto)
   - Verificar: `git --version`
   - Instalar: `sudo apt install git`

## Dependências do Projeto

### PHP
- Nenhuma dependência externa (usa apenas extensões nativas)
- Arquivos necessários:
  - `php-api/config.php`
  - `php-api/user.php`
  - `php-api/messages.php`

### Elixir/Phoenix
- Dependências gerenciadas pelo Mix (arquivo `mix.exs`)
- Principais dependências:
  - `phoenix` ~> 1.7.0
  - `phoenix_ecto` ~> 4.4
  - `ecto_sql` ~> 3.6
  - `myxql` ~> 0.6.0 (driver MySQL)
  - `jason` ~> 1.2 (JSON)
  - `plug_cowboy` ~> 2.5 (servidor HTTP)

### Frontend
- Nenhuma dependência externa
- Usa apenas APIs nativas do navegador:
  - WebSocket API
  - Fetch API
  - LocalStorage API

## Arquivos Necessários para Rodar

### Estrutura Mínima

```
chat_online_gui_teste/
├── database/
│   └── schema.sql              # ✅ OBRIGATÓRIO - Schema do banco
├── php-api/
│   ├── config.php              # ✅ OBRIGATÓRIO - Config MySQL
│   ├── user.php                # ✅ OBRIGATÓRIO - API usuários
│   └── messages.php            # ✅ OBRIGATÓRIO - API mensagens
├── elixir-chat/
│   ├── mix.exs                 # ✅ OBRIGATÓRIO - Dependências
│   ├── config/
│   │   ├── config.exs          # ✅ OBRIGATÓRIO - Config geral
│   │   └── dev.exs             # ✅ OBRIGATÓRIO - Config dev
│   └── lib/                    # ✅ OBRIGATÓRIO - Código fonte
│       ├── chat_online/
│       │   ├── application.ex
│       │   └── repo.ex
│       └── chat_online_web/
│           ├── endpoint.ex
│           ├── router.ex
│           └── channels/
│               ├── user_socket.ex
│               └── chat_channel.ex
└── public/                     # ✅ OBRIGATÓRIO - Frontend
    ├── index.html
    ├── css/
    │   └── style.css
    └── js/
        └── chat.js
```

## Checklist de Instalação

### 1. Verificar Instalações
```bash
# PHP
php -v                    # Deve mostrar 8.0+

# MySQL
mysql --version           # Deve mostrar 8.0+

# Elixir
elixir --version          # Deve mostrar 1.15+

# Mix
mix --version             # Deve mostrar Mix 1.15+
```

### 2. Instalar Dependências do Sistema

#### Ubuntu/Debian:
```bash
sudo apt update
sudo apt install -y php php-cli php-mysql php-json \
                     mysql-server \
                     erlang elixir \
                     python3
```

#### Arch Linux:
```bash
sudo pacman -S php php-mysql \
                mysql \
                erlang elixir \
                python
```

#### Fedora:
```bash
sudo dnf install php php-cli php-mysqlnd \
                 mysql-server \
                 erlang elixir \
                 python3
```

### 3. Instalar Dependências do Projeto

#### PHP:
```bash
# Nenhuma dependência externa necessária
# Apenas verificar extensões
php -m | grep -E "pdo|mysql|json"
```

#### Phoenix/Elixir:
```bash
cd elixir-chat
mix deps.get          # Baixa dependências
mix compile            # Compila o projeto
```

### 4. Configurar Banco de Dados

```bash
# Criar banco
mysql -u root -p < database/schema.sql

# Ou manualmente
mysql -u root -p
CREATE DATABASE chat_online;
USE chat_online;
SOURCE database/schema.sql;
```

### 5. Configurar Credenciais

#### PHP (`php-api/config.php`):
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'chat_online');
define('DB_USER', 'root');        // Seu usuário
define('DB_PASS', '');            // Sua senha
```

#### Phoenix (`elixir-chat/config/dev.exs`):
```elixir
config :chat_online, ChatOnline.Repo,
  username: "root",        # Seu usuário
  password: "",            # Sua senha
  hostname: "localhost",
  database: "chat_online"
```

## Verificação Final

Execute este comando para verificar tudo:

```bash
# Verificar PHP
php -v && php -m | grep -q pdo_mysql && echo "✅ PHP OK" || echo "❌ PHP com problemas"

# Verificar MySQL
mysql -u root -e "SELECT 1" > /dev/null 2>&1 && echo "✅ MySQL OK" || echo "❌ MySQL não conecta"

# Verificar Elixir
elixir --version > /dev/null 2>&1 && echo "✅ Elixir OK" || echo "❌ Elixir não encontrado"

# Verificar Mix
mix --version > /dev/null 2>&1 && echo "✅ Mix OK" || echo "❌ Mix não encontrado"

# Verificar banco
mysql -u root -e "USE chat_online" > /dev/null 2>&1 && echo "✅ Banco OK" || echo "❌ Banco não existe"

# Verificar dependências Phoenix
cd elixir-chat && mix deps.get > /dev/null 2>&1 && echo "✅ Dependências Phoenix OK" || echo "❌ Erro nas dependências"
```

## Problemas Comuns

### PHP não encontra pdo_mysql
```bash
sudo apt install php-mysql
sudo systemctl restart php8.1-fpm  # Se usar FPM
```

### Mix não encontra dependências
```bash
cd elixir-chat
mix deps.clean --all
mix deps.get
mix compile
```

### Erro de permissão MySQL
```bash
sudo mysql -u root
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'sua_senha';
FLUSH PRIVILEGES;
```

### Porta já em uso
```bash
# Ver qual processo está usando
sudo lsof -i :4000
sudo lsof -i :8000
sudo lsof -i :8080

# Matar processo
sudo kill -9 <PID>
```

## Versões Testadas

- PHP 8.1, 8.2
- MySQL 8.0
- Elixir 1.15.0, 1.16.0
- Erlang/OTP 25.3, 26.0
- Ubuntu 22.04, Arch Linux

## Próximos Passos

Após instalar tudo:
1. Execute `./start-dev.sh` ou siga `COMO_RODAR.md`
2. Acesse http://localhost:8080
3. Digite um nome e comece a conversar!


