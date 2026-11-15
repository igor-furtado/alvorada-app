# Prumo.app

[![AI Ready](https://img.shields.io/badge/AI--Ready-yes-brightgreen?style=flat)](https://github.com/johnpapa/ai-ready)

Aplicação web para organizar Concursos, Editais, Disciplinas e Tópicos em um catálogo compartilhado. O projeto combina uma interface Flutter Web, uma API Go e persistência MySQL.

## Executar localmente

Inicie a API e o banco de dados na raiz do repositório:

```bash
docker compose up -d --build
```

Em outro terminal, inicie a interface:

```bash
cd app
flutter pub get
flutter run -d chrome
```

A API responde em `http://localhost:8080`, a documentação interativa em `http://localhost:8080/docs/` e o Flutter usa esse endereço por padrão.

## Verificações

```bash
cd api
go test ./...
go build ./...

cd ../app
flutter analyze
flutter test
flutter build web
```

## Documentação

- [`CONTEXT.md`](CONTEXT.md): vocabulário canônico do produto.
- [`AGENTS.md`](AGENTS.md): comandos, convenções, matriz de manutenção e limites de autonomia.
- [`infra/docs/agents/database.md`](infra/docs/agents/database.md): convenções de persistência e migração.
- [`api/docs/openapi.yaml`](api/docs/openapi.yaml): contrato HTTP.

## Contributing

1. Faça um fork ou crie uma branch curta a partir de `main`.
2. Mantenha a mudança focada e atualize os arquivos correlatos indicados em `AGENTS.md`.
3. Execute as verificações de Go e Flutter acima.
4. Abra um pull request descrevendo o comportamento alterado e como ele foi testado.

Ao revisar com agentes, use os revisores de `.github/agents/` em modelos diferentes quando possível.
