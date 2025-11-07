# 🔧 Corrigir Acesso MySQL/MariaDB

## Problema: "Access denied for user 'root'@'localhost'"

No Arch Linux, o MariaDB não permite login do root via linha de comando sem `sudo` por padrão.

## Solução Rápida

### Opção 1: Criar usuário específico (Recomendado)

```bash
# Conectar como root via sudo
sudo mysql

# No MySQL, execute:
CREATE USER 'chat_user'@'localhost' IDENTIFIED BY 'chat123';
GRANT ALL PRIVILEGES ON chat_online.* TO 'chat_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

Depois, edite os arquivos de configuração:

**`php-api/config.php`:**
```php
define('DB_USER', 'chat_user');
define('DB_PASS', 'chat123');
```

**`elixir-chat/config/dev.exs`:**
```elixir
config :chat_online, ChatOnline.Repo,
  username: "chat_user",
  password: "chat123",
  hostname: "localhost",
  database: "chat_online"
```

### Opção 2: Habilitar login root com senha

```bash
# Conectar como root
sudo mysql

# No MySQL, execute:
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'sua_senha';
FLUSH PRIVILEGES;
EXIT;
```

Depois, edite os arquivos de configuração com a senha escolhida.

### Opção 3: Usar autenticação socket (Arch Linux)

Se você não quer criar senha, pode usar autenticação via socket:

**`php-api/config.php`:**
```php
// Para Arch Linux, usar socket ao invés de TCP
define('DB_HOST', 'localhost');
define('DB_SOCKET', '/run/mysqld/mysqld.sock'); // Caminho do socket
define('DB_NAME', 'chat_online');
define('DB_USER', 'root');
define('DB_PASS', '');

// Na função getDBConnection, use:
function getDBConnection() {
    try {
        $dsn = "mysql:unix_socket=" . DB_SOCKET . ";dbname=" . DB_NAME . ";charset=" . DB_CHARSET;
        $options = [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ];
        return new PDO($dsn, DB_USER, DB_PASS, $options);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Database connection failed: ' . $e->getMessage()]);
        exit;
    }
}
```

## Verificar Acesso

```bash
# Testar conexão
mysql -u chat_user -p chat_online
# Digite a senha quando pedir

# Ou se usar root com senha
mysql -u root -p chat_online
```

## Testar PHP

```bash
# Testar se PHP consegue conectar
php -r "
require 'php-api/config.php';
try {
    \$pdo = getDBConnection();
    echo '✅ Conexão OK\n';
} catch (Exception \$e) {
    echo '❌ Erro: ' . \$e->getMessage() . '\n';
}
"
```

## Testar Elixir

```bash
cd elixir-chat
iex -S mix

# No IEx, teste:
ChatOnline.Repo.query("SELECT 1", [])
```

## Solução Rápida (Script)

Execute:

```bash
# Criar usuário automaticamente
sudo mysql << EOF
CREATE USER IF NOT EXISTS 'chat_user'@'localhost' IDENTIFIED BY 'chat123';
GRANT ALL PRIVILEGES ON chat_online.* TO 'chat_user'@'localhost';
FLUSH PRIVILEGES;
EOF

# Atualizar config.php
sed -i "s/define('DB_USER', '.*');/define('DB_USER', 'chat_user');/" php-api/config.php
sed -i "s/define('DB_PASS', '.*');/define('DB_PASS', 'chat123');/" php-api/config.php

# Atualizar dev.exs
sed -i 's/username: ".*",/username: "chat_user",/' elixir-chat/config/dev.exs
sed -i 's/password: ".*",/password: "chat123",/' elixir-chat/config/dev.exs
```

