---
name: shipping-a-change
description: What to update when you change something in this repo, and what "done" requires. Use before opening a pull request.
---

# Shipping a change

## Add a new vertical feature

1. `api/internal/domain/`, `api/internal/application/`, `api/internal/infrastructure/mysql/`, and `api/internal/presentation/httpapi/` — implement the server-side chain.
2. `api/docs/openapi.yaml` — declare the endpoint and payload.
3. `app/lib/features/<feature>/` — add the Flutter domain, data, and presentation layers.
4. `app/lib/app/app_dependencies.dart`, `app_router.dart`, and `app_shell.dart` — register dependencies and navigation.
5. `app/lib/l10n/app_pt.arb`, `app_en.arb`, and both test trees — add visible copy and coverage.

## When you change this, also change that

| Change | Also update |
|---|---|
| `api/internal/presentation/httpapi/` route or payload | `api/docs/openapi.yaml`, Flutter `data/`, and serialization tests on both sides |
| Persistent schema or invariant | `infra/mysql/init.sql`, Go migration/schema code, repository queries, database docs, and migration tests |
| Flutter top-level destination | `app/lib/app/app_router.dart`, `app/lib/app/app_shell.dart`, ARB navigation keys, and `app/test/app_navigation_test.dart` |
| Design-system component or token | `app/lib/core/design_system/design_system.dart` and the matching widget/token test |
| Product term or visible behavior | `CONTEXT.md`, both ARB files, and `api/docs/openapi.yaml` when externally visible |

## Done

- `cd api && go test ./... && go build ./...` passes.
- `cd app && flutter analyze && flutter test && flutter build web` passes.
- `docker compose config --quiet` passes when Docker Compose or environment defaults change.
