# 🚀 Como Rodar o Servidor

## Desenvolvimento Local (Rápido)

### Pré-requisitos
- PHP 8.x instalado
- MySQL instalado e rodando
- Elixir 1.15+ instalado

### Passo 1: Configurar Banco de Dados

```bash
# Criar o banco de dados
mysql -u root -p < database/schema.sql
```

Ou manualmente:
```bash
mysql -u root -p
```

No MySQL:
```sql
CREATE DATABASE IF NOT EXISTS chat_online CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE chat_online;
SOURCE database/schema.sql;
EXIT;
```

### Passo 2: Configurar PHP

Edite `php-api/config.php` e ajuste as credenciais:

```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'chat_online');
define('DB_USER', 'root');        // Seu usuário MySQL
define('DB_PASS', '');            // Sua senha MySQL
```

### Passo 3: Configurar Phoenix

Edite `elixir-chat/config/dev.exs` e ajuste as credenciais:

```elixir
config :chat_online, ChatOnline.Repo,
  username: "root",        # Seu usuário MySQL
  password: "",            # Sua senha MySQL
  hostname: "localhost",
  database: "chat_online"
```

### Passo 4: Instalar Dependências Phoenix

```bash
cd elixir-chat
mix deps.get
mix compile
```

### Passo 5: Rodar os Servidores

Abra **3 terminais diferentes**:

#### Terminal 1 - Servidor PHP:
```bash
cd php-api
php -S localhost:8000
```

#### Terminal 2 - Servidor Phoenix:
```bash
cd elixir-chat
mix phx.server
```

#### Terminal 3 - Servidor Frontend (opcional):
```bash
cd public
python3 -m http.server 8080
```

Ou use qualquer servidor web simples:
```bash
# Com PHP
cd public
php -S localhost:8080

# Com Node.js (se tiver instalado)
cd public
npx http-server -p 8080

# Com Python 2
cd public
python -m SimpleHTTPServer 8080
```

### Passo 6: Acessar a Aplicação

Abra o navegador em: **http://localhost:8080**

---

## Produção (DigitalOcean)

### Opção 1: Usando Nginx + PHP-FPM + Phoenix

#### 1. Instalar dependências:
```bash
sudo apt update
sudo apt install -y mysql-server php8.1-fpm php8.1-mysql nginx
```

#### 2. Instalar Elixir:
```bash
sudo apt install -y erlang elixir
```

#### 3. Configurar MySQL:
```bash
sudo mysql_secure_installation
sudo mysql -u root -p
```

```sql
CREATE DATABASE chat_online;
CREATE USER 'chat_user'@'localhost' IDENTIFIED BY 'senha_segura';
GRANT ALL PRIVILEGES ON chat_online.* TO 'chat_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

```bash
mysql -u chat_user -p chat_online < database/schema.sql
```

#### 4. Copiar arquivos para /var/www:
```bash
sudo mkdir -p /var/www/chat_online
sudo cp -r * /var/www/chat_online/
sudo chown -R www-data:www-data /var/www/chat_online
```

#### 5. Configurar PHP e Phoenix:
Edite os arquivos de configuração com as credenciais corretas.

#### 6. Configurar Nginx:
```bash
sudo cp nginx.conf /etc/nginx/sites-available/chat_online
sudo ln -s /etc/nginx/sites-available/chat_online /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

#### 7. Criar serviço Systemd para Phoenix:

Crie `/etc/systemd/system/chat_online.service`:

```ini
[Unit]
Description=Chat Online Phoenix Server
After=network.target mysql.service

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/chat_online/elixir-chat
Environment=MIX_ENV=prod
Environment=PORT=4000
ExecStart=/usr/bin/mix phx.server
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
cd /var/www/chat_online/elixir-chat
sudo -u www-data mix deps.get
sudo -u www-data MIX_ENV=prod mix compile

sudo systemctl daemon-reload
sudo systemctl enable chat_online
sudo systemctl start chat_online
sudo systemctl status chat_online
```

#### 8. Verificar:
```bash
# Ver logs do Phoenix
sudo journalctl -u chat_online -f

# Ver logs do Nginx
sudo tail -f /var/log/nginx/error.log

# Verificar se está rodando
curl http://localhost
```

---

## Verificação Rápida

### Verificar se PHP está rodando:
```bash
curl http://localhost:8000/php-api/user.php
# Deve retornar erro de método, mas não erro de conexão
```

### Verificar se Phoenix está rodando:
```bash
curl http://localhost:4000
# Deve retornar algo (mesmo que erro 404)
```

### Verificar se MySQL está rodando:
```bash
mysql -u root -p -e "SHOW DATABASES;" | grep chat_online
# Deve mostrar: chat_online
```

---

## Troubleshooting

### Erro: "Port already in use"
```bash
# Ver qual processo está usando a porta
sudo lsof -i :4000
sudo lsof -i :8000
sudo lsof -i :8080

# Matar o processo
sudo kill -9 <PID>
```

### Erro: "Database connection failed"
- Verifique se MySQL está rodando: `sudo systemctl status mysql`
- Verifique credenciais nos arquivos de configuração
- Teste conexão: `mysql -u root -p chat_online`

### Erro: "Mix not found"
```bash
# Adicionar ao PATH ou usar caminho completo
export PATH=$PATH:/usr/local/bin
# Ou
/usr/local/bin/mix phx.server
```

### Phoenix não conecta ao MySQL
- Verifique se o banco existe: `mysql -u root -p -e "SHOW DATABASES;"`
- Verifique se o usuário tem permissões
- Verifique logs: `cd elixir-chat && mix phx.server` (modo verbose)

### WebSocket não conecta
- Verifique se Phoenix está rodando na porta 4000
- Abra console do navegador (F12) e veja erros
- Verifique se a URL do WebSocket está correta no `chat.js`

---

## Comandos Úteis

### Parar todos os servidores:
```bash
# PHP
pkill -f "php -S"

# Phoenix
pkill -f "mix phx.server"

# Ou Ctrl+C nos terminais
```

### Reiniciar Phoenix (produção):
```bash
sudo systemctl restart chat_online
```

### Ver logs em tempo real:
```bash
# Phoenix (produção)
sudo journalctl -u chat_online -f

# Nginx
sudo tail -f /var/log/nginx/error.log

# PHP-FPM
sudo tail -f /var/log/php8.1-fpm.log
```

---

## Estrutura de Portas

- **8080**: Frontend (desenvolvimento)
- **8000**: API PHP (desenvolvimento)
- **4000**: Phoenix WebSocket (desenvolvimento e produção)
- **80/443**: Nginx (produção, faz proxy para os outros)


