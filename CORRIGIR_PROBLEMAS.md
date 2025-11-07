# 🔧 Correção de Problemas

## Problemas Corrigidos

### ✅ 1. Erro de Compilação Phoenix (Gettext)

**Problema:** `module Gettext is not loaded`

**Solução:** Adicionei a dependência `gettext` no `mix.exs` e instalei.

**Status:** ✅ Corrigido - Execute:
```bash
cd elixir-chat
mix deps.get
mix compile
```

### ✅ 2. MySQL/MariaDB não está rodando

**Problema:** Script não encontrava MySQL rodando

**Solução:** Atualizei `start-dev.sh` para:
- Detectar automaticamente se é `mysql` ou `mariadb`
- Tentar iniciar automaticamente
- Dar mensagens mais claras

## Como Resolver Agora

### Passo 1: Iniciar MariaDB

```bash
# Verificar se está instalado
sudo systemctl status mariadb

# Se não estiver instalado, instale:
sudo pacman -S mariadb
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl enable mariadb
sudo systemctl start mariadb

# Verificar se está rodando
sudo systemctl status mariadb
```

### Passo 2: Criar Banco de Dados

```bash
# Se MariaDB não tiver senha para root:
mysql -u root < database/schema.sql

# Se tiver senha:
mysql -u root -p < database/schema.sql
```

### Passo 3: Recompilar Phoenix

```bash
cd elixir-chat
mix deps.get
mix compile
```

### Passo 4: Rodar Servidores

```bash
# Voltar para raiz do projeto
cd ..

# Rodar script
./start-dev.sh
```

## Verificação Rápida

Execute para verificar tudo:

```bash
# 1. MariaDB rodando?
sudo systemctl is-active mariadb && echo "✅ MariaDB ativo" || echo "❌ MariaDB inativo"

# 2. Banco existe?
mysql -u root -e "USE chat_online" 2>/dev/null && echo "✅ Banco existe" || echo "❌ Banco não existe"

# 3. Phoenix compila?
cd elixir-chat && mix compile 2>&1 | tail -3
```

## Comandos Úteis

```bash
# Iniciar MariaDB
sudo systemctl start mariadb

# Parar MariaDB
sudo systemctl stop mariadb

# Ver status
sudo systemctl status mariadb

# Ver logs
sudo journalctl -u mariadb -f

# Conectar ao MySQL
mysql -u root

# Ver bancos de dados
mysql -u root -e "SHOW DATABASES;"
```

## Se Ainda Não Funcionar

1. **MariaDB não inicia:**
   ```bash
   sudo journalctl -u mariadb -n 50
   # Verifique os logs para erros
   ```

2. **Erro de permissão:**
   ```bash
   sudo chown -R mysql:mysql /var/lib/mysql
   sudo systemctl restart mariadb
   ```

3. **Porta já em uso:**
   ```bash
   sudo lsof -i :3306
   # Se houver processo, mate-o ou configure outra porta
   ```


