# N8N Queue Mode - Docker Compose

![N8N Logo](https://docs.n8n.io/assets/images/n8n-logo.png)

Este projeto configura o N8N em **modo queue** usando Docker Compose, proporcionando uma arquitetura escalável e robusta para automação de workflows.

## 📋 Índice

- [Sobre o Projeto](#-sobre-o-projeto)
- [Arquitetura](#️-arquitetura)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação](#-instalação)
- [Configuração](#️-configuração)
- [Uso](#-uso)
- [Monitoramento](#-monitoramento)
- [Troubleshooting](#-troubleshooting)

## 🚀 Sobre o Projeto

Este setup implementa o N8N em **modo queue** com as seguintes características:

- **Escalabilidade**: Múltiplos workers para processamento paralelo
- **Alta Disponibilidade**: Separação de responsabilidades entre serviços
- **Performance**: Redis para gerenciamento de filas
- **Persistência**: PostgreSQL como banco de dados principal
- **SSL/TLS**: Caddy como proxy reverso com certificados automáticos

## 🏗️ Arquitetura

O projeto utiliza uma arquitetura distribuída com os seguintes componentes:

```text
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    Caddy    │    │  N8N Main   │    │ N8N Worker  │
│ (Proxy/SSL) │────│ (Interface) │    │(Processor)  │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       │                   └───────┬───────────┘
       │                           │
┌─────────────┐            ┌─────────────┐
│N8N Webhook  │            │    Redis    │
│ (Endpoints) │            │   (Queue)   │
└─────────────┘            └─────────────┘
       │                           │
       └──────────┬────────────────┘
                  │
          ┌─────────────┐
          │ PostgreSQL  │
          │ (Database)  │
          └─────────────┘
```

### Componentes

- **Caddy**: Proxy reverso com SSL automático via Let's Encrypt
- **N8N Main**: Interface principal do N8N (editor de workflows)
- **N8N Worker**: Processador de execuções em background
- **N8N Webhook**: Manipulador dedicado de webhooks
- **PostgreSQL**: Banco de dados para persistência
- **Redis**: Sistema de filas para coordenação

## 📋 Pré-requisitos

- Docker 20.10+
- Docker Compose 2.0+
- Domínio próprio com DNS configurado
- Portas 80 e 443 liberadas no firewall

## 🔧 Instalação

1. **Clone o repositório**:

```bash
git clone https://github.com/dario-bastos-dev/n8n-model.git
cd n8n-model
```

2. **Configure as variáveis de ambiente**:

```bash
cp .env.example .env
```

3. **Edite o arquivo `.env`** com suas configurações:

```bash
nano .env
```

4. **Execute o script de inicialização**:

```bash
chmod +x init.sh 
./init.sh
```

5. **Habilite o script de Restart**:

```bash
chmod +x restart.sh
```

## ⚙️ Configuração

### Variáveis de Ambiente Obrigatórias

Edite o arquivo `.env` com os seguintes valores:

```bash
# Configuração Básica
N8N_HOST=n8n.seudominio.com
N8N_PROTOCOL=https
WEBHOOK_URL=https://n8n.seudominio.com
GENERIC_TIMEZONE=America/Sao_Paulo

# Segurança - IMPORTANTE: Gere uma chave segura!
N8N_ENCRYPTION_KEY=sua-chave-de-32-bytes-aqui

# PostgreSQL
POSTGRES_USER=n8n
POSTGRES_PASSWORD=sua-senha-postgres-segura
POSTGRES_DB=n8n

# Worker
WORKER_CONCURRENCY=5
```

### Gerando Chave de Criptografia

```bash
openssl rand -hex 32
```

### Configuração do Caddy

Edite o arquivo `Caddyfile` e substitua:

- `seu-email@dominio.com` pelo seu email
- `n8n.seu-dominio.com` pelo seu domínio

## 🚀 Uso

### Iniciar os Serviços

```bash
docker compose up -d
```

### Verificar Status

```bash
docker compose ps
```

### Visualizar Logs

```bash
# Todos os serviços
docker compose logs -f

# Serviço específico
docker compose logs -f n8n-main
```

### Parar os Serviços

```bash
docker compose down
```

### Reiniciar os Serviços

```bash
./restart.sh
```

### Backup dos Dados

```bash
# Backup PostgreSQL
docker compose exec postgres pg_dump -U n8n n8n > backup_$(date +%Y%m%d_%H%M%S).sql

# Backup completo dos volumes
docker run --rm -v n8n-queue_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres_backup.tar.gz -C /data .
```

## 📊 Monitoramento

### Verificar Saúde dos Serviços

```bash
# Status geral
docker compose ps

# Logs em tempo real
docker compose logs -f

# Verificar uso de recursos
docker stats
```

### Métricas do N8N

O N8N está configurado com métricas habilitadas. As métricas incluem:

- Estatísticas da fila
- Métricas de workflow
- Eventos do message bus

### Verificar Redis

```bash
docker compose exec redis redis-cli info
```

### Verificar PostgreSQL

```bash
docker compose exec postgres psql -U n8n -d n8n -c "\dt"
```

## 🔧 Troubleshooting

### Problemas Comuns

#### 1. Serviços não iniciam

```bash
# Verificar logs
docker compose logs

# Reiniciar serviços
docker compose restart
```

#### 2. Erro de conexão com banco

```bash
# Verificar se PostgreSQL está rodando
docker compose ps postgres

# Verificar logs do PostgreSQL
docker compose logs postgres
```

#### 3. Problemas de SSL/Certificado

```bash
# Verificar logs do Caddy
docker compose logs caddy

# Verificar configuração DNS
nslookup n8n.seudominio.com
```

#### 4. Worker não processa workflows

```bash
# Verificar logs do worker
docker compose logs n8n-worker

# Verificar conexão Redis
docker compose exec redis redis-cli ping
```

### Comandos Úteis

```bash
# Reiniciar apenas um serviço
docker compose restart n8n-main

# Acessar shell do container
docker compose exec n8n-main sh

# Limpar volumes (CUIDADO: perde dados)
docker compose down -v

# Verificar portas em uso
netstat -tlnp | grep :80
```

## 🔒 Segurança

### Recomendações

1. **Use senhas fortes** para PostgreSQL e chave de criptografia
2. **Configure firewall** adequadamente
3. **Mantenha containers atualizados**:

   ```bash
   docker compose pull
   docker compose down
   docker compose up -d
   ```

4. **Monitore logs** regularmente
5. **Faça backups** periódicos

### Atualizações

```bash
# Baixar imagens atualizadas
docker compose pull

# Aplicar atualizações
docker compose up -d

# Remover imagens antigas
docker image prune
```

## 📈 Escalabilidade

### Adicionar Mais Workers

Para aumentar a capacidade de processamento, edite o `compose.yml` e adicione mais workers:

```yaml
n8n-worker-2:
  image: docker.n8n.io/n8nio/n8n:latest
  container_name: n8n-worker-2
  # ... mesma configuração do n8n-worker
```

### Ajustar Concorrência

Modifique a variável `WORKER_CONCURRENCY` no arquivo `.env` para controlar quantos jobs cada worker processa simultaneamente.