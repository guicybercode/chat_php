# Chat Online - Aplicação Retro Anos 2000

Aplicação de chat online em grupo com visual retro inspirado em MSN, Orkut e MySpace.

## 🛠️ Tecnologias

- **Backend API**: PHP 8.x (REST API)
- **Backend Real-time**: Elixir/Phoenix (WebSockets)
- **Banco de Dados**: MySQL 8.0
- **Frontend**: HTML5, CSS3, JavaScript (ES6+)

## 📁 Estrutura do Projeto

```
/
├── php-api/              # API REST em PHP
│   ├── config.php        # Configuração MySQL
│   ├── user.php          # Endpoint de usuários
│   └── messages.php      # Endpoint de mensagens
├── elixir-chat/          # Servidor Phoenix
│   ├── mix.exs
│   ├── config/
│   └── lib/
├── public/               # Frontend
│   ├── index.html
│   ├── css/
│   │   └── style.css
│   └── js/
│       └── chat.js
├── database/
│   └── schema.sql        # Schema MySQL
├── nginx.conf            # Configuração Nginx
└── README.md
```

## 🚀 Instalação e Configuração

### Pré-requisitos

- PHP 8.x com extensões: pdo, pdo_mysql
- Elixir 1.15+ e Erlang/OTP 25+
- MySQL 8.0
- Nginx (para produção)
- Node.js (para compilar assets do Phoenix, opcional)

### 1. Banco de Dados

```bash
# Criar banco de dados
mysql -u root -p < database/schema.sql
```

Ou execute manualmente:
```sql
CREATE DATABASE chat_online;
USE chat_online;
-- Execute o conteúdo de database/schema.sql
```

### 2. Configurar PHP

Edite `php-api/config.php` com suas credenciais MySQL:

```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'chat_online');
define('DB_USER', 'seu_usuario');
define('DB_PASS', 'sua_senha');
```

### 3. Configurar Phoenix

Edite `elixir-chat/config/config.exs` e `config/dev.exs` com suas credenciais:

```elixir
config :chat_online, ChatOnline.Repo,
  username: "seu_usuario",
  password: "sua_senha",
  hostname: "localhost",
  database: "chat_online"
```

### 4. Instalar Dependências Phoenix

```bash
cd elixir-chat
mix deps.get
mix compile
```

### 5. Iniciar Servidores

#### Desenvolvimento Local

**Terminal 1 - PHP (usando servidor built-in):**
```bash
cd php-api
php -S localhost:8000
```

**Terminal 2 - Phoenix:**
```bash
cd elixir-chat
mix phx.server
```

**Terminal 3 - Frontend (opcional, ou use servidor web):**
```bash
cd public
python3 -m http.server 8080
```

Acesse: `http://localhost:8080`

#### Produção (DigitalOcean)

1. **Configurar PHP-FPM:**
```bash
sudo apt update
sudo apt install php-fpm php-mysql nginx mysql-server
```

2. **Configurar Nginx:**
```bash
sudo cp nginx.conf /etc/nginx/sites-available/chat_online
sudo ln -s /etc/nginx/sites-available/chat_online /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

3. **Configurar Phoenix como serviço:**

Crie `/etc/systemd/system/chat_online.service`:

```ini
[Unit]
Description=Chat Online Phoenix Server
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/chat_online/elixir-chat
Environment=MIX_ENV=prod
Environment=PORT=4000
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
```

4. **Configurar Firewall:**
```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 4000/tcp  # Apenas se necessário
```

5. **Build Phoenix para produção:**
```bash
cd elixir-chat
MIX_ENV=prod mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix phx.digest
```

## 🔧 Configuração de Produção

### Variáveis de Ambiente

Crie um arquivo `.env` ou configure variáveis de ambiente:

```bash
export DB_USER="seu_usuario"
export DB_PASS="sua_senha"
export DB_HOST="localhost"
export DB_NAME="chat_online"
export SECRET_KEY_BASE="$(mix phx.gen.secret)"
export PORT=4000
```

### Segurança

1. **Gere secret key para Phoenix:**
```bash
cd elixir-chat
mix phx.gen.secret
```

2. **Atualize `config/prod.exs`** com o secret key gerado.

3. **Configure SSL/HTTPS** usando Let's Encrypt:
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d seu-dominio.com
```

## 📝 Uso

1. Acesse a aplicação no navegador
2. Digite um nome de usuário (2-50 caracteres)
3. Clique em "ENTRAR"
4. Comece a conversar na sala de chat!

## 🎨 Características do Design Retro

- Cores vibrantes (roxo, rosa, azul, verde neon)
- Fontes Comic Sans MS
- Bordas arredondadas com sombras exageradas
- Gradientes chamativos
- Animações (blink, glow, bounce)
- Estilo Y2K inspirado em MSN/Orkut/MySpace

## 🐛 Troubleshooting

### Phoenix não conecta
- Verifique se a porta 4000 está aberta
- Verifique logs: `journalctl -u chat_online -f`
- Teste conexão: `curl http://localhost:4000/socket/websocket`

### PHP não funciona
- Verifique se PHP-FPM está rodando: `sudo systemctl status php8.1-fpm`
- Verifique permissões dos arquivos
- Verifique logs do Nginx: `sudo tail -f /var/log/nginx/error.log`

### WebSocket não conecta
- Verifique se o Nginx está fazendo proxy corretamente
- Verifique CORS no Phoenix
- Abra console do navegador (F12) para ver erros

## 📄 Licença

Este projeto é open source e está disponível para uso livre.

## 👨‍💻 Desenvolvido com

- PHP 8.x
- Elixir/Phoenix
- MySQL
- HTML5/CSS3/JavaScript
- Muito ❤️ e nostalgia dos anos 2000!


