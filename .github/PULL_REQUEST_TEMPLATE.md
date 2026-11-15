## Descrição

Explique o problema resolvido e o resultado observável desta mudança.

## Alterações

-

## Como testar

Liste os comandos executados e os cenários verificados.

## Checklist

- [ ] `cd api && go test ./...` passa quando a API foi alterada.
- [ ] `cd app && flutter analyze && flutter test && flutter build web` passa quando o app foi alterado.
- [ ] `api/docs/openapi.yaml`, serviços Flutter e testes de serialização foram atualizados quando o contrato HTTP mudou.
- [ ] Migrações e alterações de `infra/mysql/init.sql` foram revisadas quanto a perda ou reescrita de dados.
- [ ] `CONTEXT.md`, os dois ARBs e o OpenAPI foram atualizados quando o vocabulário visível mudou.

Assisted by [ai-ready](https://github.com/johnpapa/ai-ready)
