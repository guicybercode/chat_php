# 📁 Arquivos Necessários para Rodar

## Estrutura Completa do Projeto

```
chat_online_gui_teste/
│
├── 📄 REQUISITOS.md              # Este arquivo - lista de dependências
├── 📄 COMO_RODAR.md              # Guia de como rodar
├── 📄 INSTALL.md                 # Guia de instalação produção
├── 📄 README.md                  # Documentação principal
│
├── 📂 database/
│   └── 📄 schema.sql             # ✅ OBRIGATÓRIO - Schema MySQL
│
├── 📂 php-api/
│   ├── 📄 config.php             # ✅ OBRIGATÓRIO - Config MySQL
│   ├── 📄 user.php               # ✅ OBRIGATÓRIO - API criar usuário
│   ├── 📄 messages.php           # ✅ OBRIGATÓRIO - API mensagens
│   └── 📄 .htaccess              # Opcional - Roteamento Apache
│
├── 📂 elixir-chat/
│   ├── 📄 mix.exs                # ✅ OBRIGATÓRIO - Dependências Elixir
│   ├── 📄 .formatter.exs         # Opcional - Formatação código
│   │
│   ├── 📂 config/
│   │   ├── 📄 config.exs         # ✅ OBRIGATÓRIO - Config geral
│   │   ├── 📄 dev.exs            # ✅ OBRIGATÓRIO - Config desenvolvimento
│   │   ├── 📄 prod.exs           # Opcional - Config produção
│   │   ├── 📄 test.exs            # Opcional - Config testes
│   │   └── 📄 runtime.exs        # Opcional - Config runtime
│   │
│   ├── 📂 lib/
│   │   ├── 📂 chat_online/
│   │   │   ├── 📄 application.ex # ✅ OBRIGATÓRIO - App principal
│   │   │   └── 📄 repo.ex        # ✅ OBRIGATÓRIO - Repositório Ecto
│   │   │
│   │   └── 📂 chat_online_web/
│   │       ├── 📄 endpoint.ex     # ✅ OBRIGATÓRIO - Endpoint Phoenix
│   │       ├── 📄 router.ex      # ✅ OBRIGATÓRIO - Rotas
│   │       ├── 📄 error_json.ex  # Opcional - Tratamento erros
│   │       ├── 📄 gettext.ex     # Opcional - Internacionalização
│   │       ├── 📄 chat_online_web.ex # ✅ OBRIGATÓRIO - Macros
│   │       │
│   │       └── 📂 channels/
│   │           ├── 📄 user_socket.ex    # ✅ OBRIGATÓRIO - Socket WebSocket
│   │           └── 📄 chat_channel.ex   # ✅ OBRIGATÓRIO - Channel chat
│   │
│   └── 📂 priv/
│       └── 📂 repo/
│           └── 📄 seeds.exs       # Opcional - Seeds banco
│
├── 📂 public/
│   ├── 📄 index.html              # ✅ OBRIGATÓRIO - Página principal
│   │
│   ├── 📂 css/
│   │   └── 📄 style.css           # ✅ OBRIGATÓRIO - Estilos retro
│   │
│   └── 📂 js/
│       └── 📄 chat.js             # ✅ OBRIGATÓRIO - Lógica frontend
│
├── 📄 nginx.conf                  # Opcional - Config Nginx produção
├── 📄 .gitignore                 # Opcional - Git ignore
├── 📄 start-dev.sh               # Opcional - Script iniciar dev
└── 📄 instalar-dependencias.sh   # Opcional - Script instalar deps
```

## Arquivos Obrigatórios (Mínimo para Funcionar)

### 1. Banco de Dados
- ✅ `database/schema.sql` - Cria tabelas `users` e `messages`

### 2. Backend PHP
- ✅ `php-api/config.php` - Configuração conexão MySQL
- ✅ `php-api/user.php` - Endpoint POST para criar/validar usuário
- ✅ `php-api/messages.php` - Endpoints GET/POST para mensagens

### 3. Backend Phoenix
- ✅ `elixir-chat/mix.exs` - Define dependências do projeto
- ✅ `elixir-chat/config/config.exs` - Configuração geral
- ✅ `elixir-chat/config/dev.exs` - Configuração desenvolvimento
- ✅ `elixir-chat/lib/chat_online/application.ex` - Inicia aplicação
- ✅ `elixir-chat/lib/chat_online/repo.ex` - Repositório Ecto
- ✅ `elixir-chat/lib/chat_online_web/endpoint.ex` - Endpoint WebSocket
- ✅ `elixir-chat/lib/chat_online_web/router.ex` - Rotas
- ✅ `elixir-chat/lib/chat_online_web.ex` - Macros e helpers
- ✅ `elixir-chat/lib/chat_online_web/channels/user_socket.ex` - Socket
- ✅ `elixir-chat/lib/chat_online_web/channels/chat_channel.ex` - Lógica chat

### 4. Frontend
- ✅ `public/index.html` - Interface HTML
- ✅ `public/css/style.css` - Estilos CSS retro
- ✅ `public/js/chat.js` - JavaScript com biblioteca Phoenix Socket

## Arquivos Opcionais (Mas Úteis)

- `php-api/.htaccess` - Roteamento Apache (se usar Apache)
- `nginx.conf` - Configuração Nginx para produção
- `start-dev.sh` - Script para iniciar servidores automaticamente
- `instalar-dependencias.sh` - Script para instalar dependências
- `.gitignore` - Arquivos a ignorar no Git
- `elixir-chat/.formatter.exs` - Formatação automática código Elixir
- `elixir-chat/config/prod.exs` - Configuração produção
- `elixir-chat/config/runtime.exs` - Configuração runtime
- `elixir-chat/priv/repo/seeds.exs` - Dados iniciais banco

## Verificação Rápida

Execute para verificar se todos os arquivos obrigatórios existem:

```bash
# Verificar estrutura
test -f database/schema.sql && echo "✅ schema.sql" || echo "❌ schema.sql"
test -f php-api/config.php && echo "✅ config.php" || echo "❌ config.php"
test -f php-api/user.php && echo "✅ user.php" || echo "❌ user.php"
test -f php-api/messages.php && echo "✅ messages.php" || echo "❌ messages.php"
test -f elixir-chat/mix.exs && echo "✅ mix.exs" || echo "❌ mix.exs"
test -f elixir-chat/lib/chat_online_web/channels/chat_channel.ex && echo "✅ chat_channel.ex" || echo "❌ chat_channel.ex"
test -f public/index.html && echo "✅ index.html" || echo "❌ index.html"
test -f public/css/style.css && echo "✅ style.css" || echo "❌ style.css"
test -f public/js/chat.js && echo "✅ chat.js" || echo "❌ chat.js"
```

## Tamanho Aproximado

- **Total**: ~500 KB (sem dependências compiladas)
- **PHP**: ~10 KB
- **Elixir/Phoenix**: ~50 KB (código fonte)
- **Frontend**: ~30 KB
- **Dependências Phoenix**: ~50 MB (após `mix deps.get`)

## Dependências Externas Necessárias

### Sistema
- PHP 8.0+ com extensões: pdo, pdo_mysql, json
- MySQL 8.0+ (ou MariaDB 10.3+)
- Elixir 1.15+ e Erlang/OTP 25+

### Elixir (instaladas via Mix)
- phoenix ~> 1.7.0
- phoenix_ecto ~> 4.4
- ecto_sql ~> 3.6
- myxql ~> 0.6.0
- jason ~> 1.2
- plug_cowboy ~> 2.5

### Frontend
- Nenhuma! Usa apenas APIs nativas do navegador

## Ordem de Criação/Verificação

1. ✅ Banco de dados (`database/schema.sql`)
2. ✅ Config PHP (`php-api/config.php`)
3. ✅ API PHP (`php-api/user.php`, `messages.php`)
4. ✅ Config Phoenix (`elixir-chat/config/*.exs`)
5. ✅ Código Phoenix (`elixir-chat/lib/**/*.ex`)
6. ✅ Frontend (`public/**/*`)

## Notas

- Todos os arquivos `.ex` e `.exs` são código Elixir
- Arquivos `.php` são código PHP
- O diretório `deps/` em `elixir-chat/` é criado automaticamente por `mix deps.get`
- O diretório `_build/` em `elixir-chat/` é criado automaticamente por `mix compile`
- Não é necessário ter Node.js instalado (Phoenix não usa assets neste projeto)


