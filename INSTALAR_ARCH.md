# 🐧 Instalação no Arch Linux

## Instalação Manual Rápida

Como você está no Arch Linux, siga estes passos:

### 1. Instalar MariaDB (MySQL compatível)

```bash
# Escolha a opção 1 (mariadb) quando o pacman perguntar
sudo pacman -S mariadb

# Inicializar MariaDB
# Tentar comando novo primeiro
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql || \
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

# Iniciar e habilitar
sudo systemctl enable mariadb
sudo systemctl start mariadb
```

### 2. Instalar Erlang e Elixir

```bash
sudo pacman -S erlang elixir
```

### 3. Verificar instalações

```bash
mysql --version
elixir --version
mix --version
```

### 4. Criar banco de dados

```bash
mysql -u root -p < database/schema.sql
```

Ou se não tiver senha:
```bash
mysql -u root < database/schema.sql
```

### 5. Instalar dependências Phoenix

```bash
cd elixir-chat
mix deps.get
mix compile
```

### 6. Configurar credenciais

Edite `php-api/config.php`:
```php
define('DB_USER', 'root');
define('DB_PASS', '');  // Vazio se não configurou senha
```

Edite `elixir-chat/config/dev.exs`:
```elixir
config :chat_online, ChatOnline.Repo,
  username: "root",
  password: "",  # Vazio se não configurou senha
```

## Script Automático Corrigido

O script `instalar-dependencias.sh` foi corrigido. Você pode executá-lo novamente:

```bash
./instalar-dependencias.sh
```

Ou use o script específico para Arch:

```bash
./instalar-arch.sh
```

## Notas Importantes

- **PHP**: No Arch, `pdo_mysql` já vem habilitado com o pacote `php`
- **MySQL**: Use `mariadb` (opção 1) - é totalmente compatível
- **Senha MySQL**: Por padrão, MariaDB no Arch não tem senha para root

## Próximos Passos

Após instalar tudo:

```bash
# Verificar instalação
./verificar-instalacao.sh

# Rodar servidores
./start-dev.sh
```

