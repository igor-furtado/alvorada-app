<div align="center">

<img src="app/assets/brand/prumo-horizontal.svg" alt="Prumo.app" width="360">

# Prumo.app

**Organização de Concursos, Editais e Disciplinas em um catálogo único.**

[Visão geral](#visão-geral) • [Executar localmente](#executar-localmente) • [Arquitetura](#arquitetura) • [API](#api) • [Qualidade](#qualidade)

</div>

## Visão geral

O Prumo reúne Concursos e Disciplinas para manter os Editais organizados em um catálogo compartilhado de Tópicos e Subtópicos.

O repositório reúne:

- uma interface responsiva em **Flutter Web**, com temas claro e escuro, navegação adaptativa e componentes acessíveis;
- uma **API REST em Go** para o catálogo de Disciplinas, Tópicos e Subtópicos;
- persistência em **MySQL 8.4**, inicializada e executada com Docker Compose;
- uma especificação **OpenAPI 3.1** servida pela própria API.

> [!IMPORTANT]
> O cadastro de Concursos e o catálogo de Disciplinas estão integrados à API e ao banco. O vínculo entre Editais e Disciplinas ainda não possui persistência e, por isso, é exibido somente para leitura.

## Experiência atual

- **Concursos:** concursos-alvo e progresso de cada Edital.
- **Disciplinas:** catálogo compartilhado de Disciplinas, Tópicos e Subtópicos, incluindo a Revisão de Véspera fixa de cada Disciplina.

## Executar localmente

### Pré-requisitos

- [Flutter 3.44+](https://docs.flutter.dev/get-started/install), com suporte a Chrome habilitado;
- [Docker](https://docs.docker.com/get-docker/) com Docker Compose.

Go 1.27+ e MySQL 8.4 só são necessários caso você prefira executar esses serviços fora dos contêineres.

### 1. Inicie o banco e a API

Na raiz do repositório:

```bash
docker compose up -d --build
```

Se quiser personalizar as credenciais locais, copie `.env.example` para `.env` antes de iniciar os serviços.

Confira se a API respondeu:

```bash
curl http://localhost:8080/health
```

A resposta esperada é `{"status":"ok"}`.

### 2. Inicie a interface

Em outro terminal:

```bash
cd app
flutter pub get
flutter run -d chrome
```

Por padrão, a camada de dados de Disciplinas acessa `http://localhost:8080`. Para usar outro endereço:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=https://api.exemplo.com
```

O Flutter informa o endereço da interface no terminal. Os demais serviços ficam disponíveis em:

| Serviço | Endereço |
| --- | --- |
| API | `http://localhost:8080` |
| Documentação interativa | `http://localhost:8080/docs/` |
| Especificação OpenAPI | `http://localhost:8080/openapi.yaml` |
| MySQL | `localhost:3306` |

Para encerrar os serviços sem apagar os dados:

```bash
docker compose down
```

O volume `concursos_app_mysql_data` preserva os registros entre execuções. Para remover também os dados locais, use `docker compose down --volumes`.

> [!CAUTION]
> As credenciais de `.env.example` são apenas para desenvolvimento local. Não as reutilize em produção.

## Configuração

O Docker Compose lê as seguintes variáveis do arquivo `.env` na raiz:

| Variável | Padrão | Finalidade |
| --- | --- | --- |
| `DB_NAME` | `estudos` | Nome do banco |
| `DB_USER` | `estudos` | Usuário da aplicação |
| `DB_PASSWORD` | `estudos` | Senha da aplicação |
| `DB_ROOT_PASSWORD` | `root` | Senha administrativa local |

Ao executar a API sem Docker, também estão disponíveis `PORT` (padrão `8080`), `DB_HOST` (padrão `127.0.0.1`) e `DB_PORT` (padrão `3306`).

O esquema MySQL usa o vocabulário do domínio em português: `concursos`, `disciplinas`, `topicos` e `subtopicos`, com colunas como `instituicao`, `cargo`, `data_prova`, `nome`, `posicao`, `criado_em` e `atualizado_em`. Ao iniciar, a API migra de forma idempotente bancos locais que ainda usam os nomes legados em inglês e cria a estrutura de Concursos quando necessário.

## Arquitetura

```text
.
├── app/                         Flutter Web
│   ├── assets/brand/            identidade visual em SVG
│   ├── docs/agents/             regras de design e experiência
│   ├── lib/src/core/            tema, navegação e biblioteca de UI
│   ├── lib/src/features/        fluxos navegáveis por área do produto
│   └── test/                    testes de widgets, tokens e acessibilidade
├── api/                         API REST em Go
│   ├── cmd/server/              composição e inicialização
│   ├── docs/                    OpenAPI e documentação embarcada
│   └── internal/
│       ├── application/         casos de uso e validações
│       ├── domain/              entidades e contratos
│       ├── infrastructure/      repositório MySQL
│       ├── platform/            conexão e recursos técnicos
│       └── presentation/        rotas e middlewares HTTP
├── infra/mysql/init.sql         esquema inicial do banco
├── docs/                        decisões e linguagem do produto
└── docker-compose.yml           ambiente local da API e do MySQL
```

A interface organiza cada funcionalidade por área e mantém componentes compartilhados em `core`. A funcionalidade Flutter de Disciplinas separa `domain`, `data` e `presentation` conforme o [guia oficial de arquitetura do Flutter](https://docs.flutter.dev/app-architecture/guide), com Bloc para estado e comandos da interface. As classes usam o conceito de negócio em português e preservam qualificadores técnicos em inglês, como `DisciplinaApiModel`, `DisciplinasRepository` e `DisciplinasBloc`. A API separa domínio, aplicação, infraestrutura e entrega HTTP.

Para entender os conceitos do produto — como Concurso, Edital, Disciplina e Revisão de Véspera — consulte [`CONTEXT.md`](CONTEXT.md). As decisões duradouras ficam em [`docs/adr/`](docs/adr/), as regras do produto em [`app/docs/agents/product/`](app/docs/agents/product/), a arquitetura de interface em [`presentation.md`](app/docs/agents/architecture/presentation.md) e os contratos visuais em [`design-system.md`](app/docs/agents/architecture/design-system.md).

## API

A API aceita e retorna JSON. O catálogo completo é obtido com:

```bash
curl http://localhost:8080/api/v1/subjects
```

Os campos serializados seguem o vocabulário em português: `nome`, `dificuldade`, `cor`, `topicos`, `obrigatorio`, `subtopicos` e `erro`.

Principais rotas:

| Método | Rota | Ação |
| --- | --- | --- |
| `GET` | `/health` | Verifica a disponibilidade |
| `GET`, `POST` | `/api/v1/concursos` | Lista ou cria Concursos |
| `PUT`, `DELETE` | `/api/v1/concursos/{id}` | Atualiza ou exclui um Concurso |
| `PUT` | `/api/v1/concursos/{id}/prioridade` | Define o Concurso prioritário |
| `PUT`, `DELETE` | `/api/v1/concursos/{id}/arquivamento` | Arquiva ou restaura um Concurso |
| `GET`, `POST` | `/api/v1/subjects` | Lista ou cria Disciplinas |
| `PATCH`, `DELETE` | `/api/v1/subjects/{id}` | Atualiza ou exclui uma Disciplina |
| `POST` | `/api/v1/subjects/{id}/topics` | Cria um Tópico |
| `PATCH`, `DELETE` | `/api/v1/topics/{id}` | Renomeia ou exclui um Tópico |
| `POST` | `/api/v1/topics/{id}/subtopics` | Cria um Subtópico |
| `PATCH`, `DELETE` | `/api/v1/subtopics/{id}` | Renomeia ou exclui um Subtópico |

A definição completa de corpos, respostas e validações está em [`api/docs/openapi.yaml`](api/docs/openapi.yaml).

## Qualidade

Execute as verificações de cada aplicação antes de enviar alterações:

```bash
# API
docker build -t prumo-api-check ./api

# Interface
cd app
flutter analyze
flutter test
flutter build web
```

O conjunto Flutter cobre navegação responsiva, preservação de estado, contraste, texto ampliado, alvos de toque e os principais fluxos de interface. A imagem Docker da API executa `go test ./...` durante o build. Com Go instalado localmente, os mesmos testes também podem ser executados dentro de `api/`.

## Referências do projeto

- [`app/docs/agents/architecture/presentation.md`](app/docs/agents/architecture/presentation.md): arquitetura de páginas, fluxos e estado de interface;
- [`app/docs/agents/architecture/design-system.md`](app/docs/agents/architecture/design-system.md): componentes, tokens e critérios visuais;
- [`app/docs/agents/product/index.md`](app/docs/agents/product/index.md): regras do produto;
- [`CONTEXT.md`](CONTEXT.md): glossário canônico do domínio;
- [`api/docs/openapi.yaml`](api/docs/openapi.yaml): contrato HTTP da API.
