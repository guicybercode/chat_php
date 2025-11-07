# Guia de Instalação Rápida

## Instalação Rápida - DigitalOcean Droplet

### 1. Preparar Servidor

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependências
sudo apt install -y mysql-server php8.1-fpm php8.1-mysql php8.1-cli nginx git curl

# Instalar Elixir/Erlang
sudo apt install -y erlang elixir
```

### 2. Configurar MySQL

```bash
# Criar banco de dados
sudo mysql -u root -p
```

No MySQL:
```sql
CREATE DATABASE chat_online CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'chat_user'@'localhost' IDENTIFIED BY 'sua_senha_segura';
GRANT ALL PRIVILEGES ON chat_online.* TO 'chat_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

```bash
# Importar schema
mysql -u chat_user -p chat_online < database/schema.sql
```

### 3. Configurar PHP

Edite `/var/www/chat_online/php-api/config.php`:
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'chat_online');
define('DB_USER', 'chat_user');
define('DB_PASS', 'sua_senha_segura');
```

### 4. Configurar Phoenix

```bash
cd /var/www/chat_online/elixir-chat

# Instalar dependências
mix deps.get

# Compilar
MIX_ENV=prod mix compile

# Gerar secret key
SECRET_KEY_BASE=$(mix phx.gen.secret)
echo "export SECRET_KEY_BASE=$SECRET_KEY_BASE" >> ~/.bashrc
```

Edite `config/prod.exs` com as credenciais do MySQL.

### 5. Configurar Nginx

```bash
sudo cp nginx.conf /etc/nginx/sites-available/chat_online
sudo ln -s /etc/nginx/sites-available/chat_online /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 6. Criar Serviço Systemd para Phoenix

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
Environment="SECRET_KEY_BASE=cole_aqui_o_secret_key_gerado"
ExecStart=/usr/local/bin/mix phx.server
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable chat_online
sudo systemctl start chat_online
sudo systemctl status chat_online
```

### 7. Configurar Firewall

```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 8. Verificar

- Acesse `http://seu-ip` no navegador
- Verifique logs: `sudo journalctl -u chat_online -f`
- Verifique Nginx: `sudo tail -f /var/log/nginx/error.log`

## Desenvolvimento Local

### Requisitos
- PHP 8.x
- MySQL
- Elixir 1.15+
- Node.js (opcional)

### Passos

1. **Banco de dados:**
```bash
mysql -u root -p < database/schema.sql
```

2. **Configurar PHP:**
Edite `php-api/config.php` com suas credenciais.

3. **Configurar Phoenix:**
Edite `elixir-chat/config/dev.exs` com suas credenciais.

4. **Iniciar servidores:**

Terminal 1 (PHP):
```bash
cd php-api
php -S localhost:8000
```

Terminal 2 (Phoenix):
```bash
cd elixir-chat
mix deps.get
mix phx.server
```

Terminal 3 (Frontend):
```bash
cd public
python3 -m http.server 8080
```

Acesse: `http://localhost:8080`

## Troubleshooting

### Phoenix não inicia
```bash
# Verificar logs
sudo journalctl -u chat_online -n 50

# Verificar se porta está em uso
sudo netstat -tlnp | grep 4000

# Reiniciar serviço
sudo systemctl restart chat_online
```

### PHP não funciona
```bash
# Verificar PHP-FPM
sudo systemctl status php8.1-fpm

# Verificar logs Nginx
sudo tail -f /var/log/nginx/error.log
```

### WebSocket não conecta
- Verifique se Nginx está fazendo proxy corretamente
- Verifique se Phoenix está rodando na porta 4000
- Abra console do navegador (F12) para ver erros

