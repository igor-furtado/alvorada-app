# Foco — gerenciador de estudos

Aplicação Flutter Web para organizar disciplinas, tópicos e subtópicos, com uma API Go e persistência em MySQL. O projeto foi separado por funcionalidades e camadas para permitir que planejamento, sessões de estudo, revisões, questões e métricas sejam adicionados sem acoplar o domínio à interface ou ao banco.

## Executar localmente

Pré-requisitos: Flutter 3.44+ e Docker com Compose.

1. Suba o banco e a API:

   ```bash
   docker compose up -d --build
   ```

2. Inicie a interface:

   ```bash
   cd app
   flutter run -d chrome
   ```

A interface ficará no endereço informado pelo Flutter. A API usa `http://localhost:8080` e o MySQL fica disponível em `localhost:3306` para acesso pelo DBeaver.

### Documentação da API

- Documentação OpenAPI interativa: `http://localhost:8080/docs/`
- Especificação OpenAPI: `http://localhost:8080/openapi.yaml`
- Arquivo-fonte: `api/docs/openapi.yaml`

As credenciais de desenvolvimento podem ser alteradas copiando `.env.example` para `.env`. Não use os valores de exemplo em produção.

## Arquitetura

```text
app/                         Flutter Web
  lib/src/core/              tema e configuração transversal
  lib/src/features/studies/
    domain/                  entidades e contratos, sem infraestrutura
    data/                    JSON, HTTP e implementação do repositório
    presentation/            estado Riverpod, páginas e componentes

api/                         API REST em Go
  cmd/server/                composição e inicialização
  internal/config/           configuração por ambiente
  internal/domain/studies/   entidades e contratos
  internal/application/      casos de uso e validações
  internal/infrastructure/   implementação MySQL
  internal/presentation/     rotas, handlers e middlewares HTTP
  internal/platform/         conexão e recursos técnicos

infra/mysql/init.sql         esquema inicial versionável
docker-compose.yml           MySQL e API
```

O domínio não conhece Flutter, HTTP ou MySQL. As dependências apontam para dentro: apresentação e infraestrutura dependem dos contratos do domínio. Novas funcionalidades devem entrar como novos módulos em `features`, compartilhando apenas elementos realmente transversais em `core`.

## Endpoints principais

- `GET /health`
- `GET|POST /api/v1/subjects`
- `PATCH|DELETE /api/v1/subjects/:id`
- `POST /api/v1/subjects/:id/topics`
- `PATCH|DELETE /api/v1/topics/:id`
- `POST /api/v1/topics/:id/subtopics`
- `PATCH|DELETE /api/v1/subtopics/:id`

## Qualidade

```bash
docker build -t estudos-api-test ./api
cd app && flutter analyze && flutter test && flutter build web
```

Para encerrar os serviços sem apagar os dados:

```bash
docker compose down
```

O volume `concursos_app_mysql_data` mantém os registros entre execuções.
