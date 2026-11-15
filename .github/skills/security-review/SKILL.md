---
name: security-review
description: Regras de segurança específicas dos limites HTTP, configuração e persistência do Prumo. Use ao alterar api/internal/presentation/httpapi, api/internal/config ou api/internal/infrastructure/mysql.
---

# Security review

## Limites de confiança deste repositório

- `api/internal/presentation/httpapi/handler.go` recebe corpos JSON e parâmetros de rota não confiáveis; preserve o limite de 1 MiB, a rejeição de campos desconhecidos e a exigência de um único objeto implementados por `decodeJSON`.
- `api/internal/config/config.go` recebe credenciais MySQL pelo ambiente; mantenha `DatabasePass` fora de respostas HTTP e dos campos enviados ao logger.
- `api/internal/infrastructure/mysql/` transforma entradas da API em consultas e executa migrações contra dados persistidos; valores externos continuam em argumentos de consulta, não em SQL interpolado.

## Antes de mesclar alterações nesses limites

- Para `api/internal/presentation/httpapi/`, execute `cd api && go test ./internal/presentation/httpapi` e confirme que `api/docs/openapi.yaml` descreve qualquer contrato alterado.
- Para `api/internal/infrastructure/mysql/`, execute `cd api && go test ./internal/infrastructure/mysql` e revise explicitamente operações que removem ou reescrevem dados.
- Para `api/internal/config/`, execute `cd api && go test ./...` e confirme que valores de `DB_PASSWORD` não aparecem em logs, erros ou respostas.
