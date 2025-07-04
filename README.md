# N8N - Ambiente de Produção com Docker Compose

Este projeto configura um ambiente completo de produção para o N8N (workflow automation tool) usando Docker Compose com arquitetura distribuída, incluindo balanceamento de carga, SSL automático e sistema de filas.

## 📋 Sobre o Projeto

O N8N é uma ferramenta de automação de workflows que permite conectar diferentes serviços e APIs de forma visual. Este setup oferece:

- **Arquitetura Distribuída**: Separação entre editor, worker e webhook para melhor performance
- **Alta Disponibilidade**: Sistema de filas com Redis para processamento distribuído
- **SSL Automático**: Certificados Let's Encrypt via Traefik
- **Banco de Dados Robusto**: PostgreSQL com extensão pgvector
- **Monitoramento**: Métricas integradas para observabilidade

## 🏗️ Arquitetura

```text
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Traefik   │────│  N8N Editor  │────│ PostgreSQL  │
│(Load Balancer)   │   (Main UI)  │    │ (Database)  │
└─────────────┘    └──────────────┘    └─────────────┘
       │                    │                   │
       │            ┌──────────────┐           │
       │────────────│ N8N Worker   │───────────┤
       │            │ (Processing) │           │
       │            └──────────────┘           │
       │                    │                   │
       │            ┌──────────────┐    ┌─────────────┐
       └────────────│ N8N Webhook  │────│    Redis    │
                    │ (Triggers)   │    │   (Queue)   │
                    └──────────────┘    └─────────────┘
```

### Componentes

- **Traefik**: Proxy reverso com SSL automático e balanceamento de carga
- **N8N Editor**: Interface principal para criação e edição de workflows
- **N8N Worker**: Processa execuções de workflows em background
- **N8N Webhook**: Gerencia triggers e webhooks externos
- **PostgreSQL**: Banco de dados principal com extensão pgvector
- **Redis**: Sistema de filas para comunicação entre componentes

## 🚀 Como Usar

### Pré-requisitos

- Docker e Docker Compose instalados
- Domínio configurado apontando para seu servidor
- Portas 80 e 443 disponíveis

### 1. Configuração Inicial

1. Clone este repositório:

```bash
git clone https://github.com/dario-bastos-dev/n8n-model.git
cd N8N
```

2. Copie o arquivo de exemplo de variáveis de ambiente:

```bash
cp .env.example .env
```

3. Edite o arquivo `.env` com suas configurações:

```bash
# Traefik - Email para certificados SSL
SSL_EMAIL=seu-email@exemplo.com

# Postgres - Senha do banco de dados
DB_POSTGRESDB_PASSWORD=sua_senha_super_segura

# N8N - Seu domínio
N8N_EDITOR_BASE_URL=n8n.seudominio.com
N8N_HOST=n8n.seudominio.com
WEBHOOK_URL=https://n8n.seudominio.com

# N8N - Chave de criptografia (gere uma aleatória)
N8N_ENCRYPTION_KEY=sua_chave_de_criptografia_muito_segura
```

### 2. Iniciando os Serviços

Execute o comando para subir todos os containers:

```bash
docker-compose up -d
```

### 3. Verificando o Status

Verifique se todos os containers estão rodando:

```bash
docker-compose ps
```

### 4. Primeiro Acesso

1. Acesse `https://n8n.seudominio.com`
2. Configure sua conta de administrador
3. Comece a criar seus workflows!

## ⚙️ Configurações Avançadas

### Variáveis de Ambiente Principais

| Variável                 | Descrição                             | Exemplo               |
| ------------------------ | ------------------------------------- | --------------------- |
| `SSL_EMAIL`              | Email para certificados Let's Encrypt | `admin@empresa.com`   |
| `N8N_HOST`               | Domínio do N8N                        | `n8n.empresa.com`     |
| `DB_POSTGRESDB_PASSWORD` | Senha do PostgreSQL                   | `senha123!`           |
| `N8N_ENCRYPTION_KEY`     | Chave para criptografia               | `chave-super-secreta` |

### Volumes Persistentes

- `./n8n-data`: Dados do N8N (workflows, credenciais, etc.)
- `./postgres-data`: Dados do PostgreSQL
- `./redis-data`: Dados do Redis
- `./traefik_data`: Certificados SSL do Traefik
- `./local-files`: Arquivos locais acessíveis pelo N8N

## 🔧 Manutenção

### Backup

Para fazer backup dos dados importantes:

```bash
# Backup do banco de dados
docker-compose exec postgres pg_dump -U postgres n8n > backup_n8n_$(date +%Y%m%d).sql

# Backup dos dados do N8N
tar -czf backup_n8n_data_$(date +%Y%m%d).tar.gz ./n8n-data
```

### Logs

Para visualizar logs de um serviço específico:

```bash
# Logs do N8N Editor
docker-compose logs -f n8n-editor

# Logs do Worker
docker-compose logs -f n8n_worker

# Logs do Traefik
docker-compose logs -f traefik
```

### Atualizações

Para atualizar o N8N para a versão mais recente:

```bash
docker-compose pull
docker-compose down
docker-compose up -d
```

## 🔍 Monitoramento

O N8N está configurado com métricas habilitadas. Você pode acessar:

- Métricas do N8N: `https://n8n.seudominio.com/metrics`
- Dashboard do Traefik: `http://seu-servidor:8080` (apenas localmente)

## 🚨 Solução de Problemas

### Problemas Comuns

1. **Certificado SSL não gerado**:

   - Verifique se o domínio está apontando corretamente
   - Confirme que as portas 80 e 443 estão abertas

2. **N8N não conecta ao banco**:

   - Verifique as credenciais no arquivo `.env`
   - Confirme que o PostgreSQL está rodando

3. **Workflows não executam**:
   - Verifique se o Redis está funcionando
   - Confirme que o Worker está ativo

### Comandos Úteis

```bash
# Reiniciar todos os serviços
docker-compose restart

# Parar todos os serviços
docker-compose down

# Ver uso de recursos
docker stats

# Acessar container do N8N
docker-compose exec n8n-editor sh
```

## 📚 Recursos Adicionais

- [Documentação Oficial do N8N](https://docs.n8n.io/)
- [Comunidade N8N](https://community.n8n.io/)
- [Templates de Workflows](https://n8n.io/workflows/)
