# Repository instructions

## Commands

- Run locally: `docker compose up -d --build`, then `cd app && flutter run -d chrome`.
- Verify the API: `cd api && go test ./... && go build ./...`.
- Verify the app: `cd app && flutter analyze && flutter test && flutter build web`.

## Conventions

- `CONTEXT.md` is the canonical product vocabulary. Update it when a domain concept or preferred term changes.
- Derive Flutter structure from the current code and tests; database rules live under `infra/docs/agents/database.md`.
- API JSON and Dart domain names use Portuguese business terms without accents; technical qualifiers stay in English.
- The repo has separate Flutter unit/widget and Go HTTP/persistence test lanes. Before accepting “untestable,” search the other lane for an existing fake, mock, or handler precedent.

## Adding a vertical feature

1. Add the Go domain and repository contract, application service operation, MySQL implementation, and HTTP handler/route under `api/internal/`.
2. Describe the endpoint and payload in `api/docs/openapi.yaml` and cover serialization plus service/repository behavior.
3. Add Flutter `domain`, `data`, and `presentation` layers under `app/lib/features/<feature>/`, with matching tests under `app/test/features/<feature>/`.
4. Register use cases in `app/lib/app/app_dependencies.dart`, routes in `app/lib/app/app_router.dart`, destinations in `app/lib/app/app_shell.dart`, and visible copy in both ARB files.
5. Run `cd app && flutter gen-l10n` after ARB changes; generated localization files are outputs, not editing targets.

## Common pitfalls

- A changed API payload also changes OpenAPI, the Flutter API service/model, and tests on both sides.
- A schema change needs `infra/mysql/init.sql` for fresh databases and an idempotent path in `api/internal/infrastructure/mysql/` for existing data.
- A new design-system component is exported from `app/lib/core/design_system/design_system.dart` and tested with the component.

## Maintenance matrix

| Change | Also update |
|---|---|
| HTTP route or payload in `api/internal/presentation/httpapi/` | `api/docs/openapi.yaml`, the relevant Flutter `data/` service/model, and Go plus Flutter serialization tests |
| Persistent schema or invariant | `infra/mysql/init.sql`, `api/internal/infrastructure/mysql/*migration.go` or `concurso_schema.go`, repository queries, `infra/docs/agents/database.md`, and migration tests |
| Flutter top-level destination | `app/lib/app/app_router.dart`, `app/lib/app/app_shell.dart`, ARB navigation keys, and `app/test/app_navigation_test.dart` |
| Design-system component or token | `app/lib/core/design_system/design_system.dart` and the matching widget/token test |
| Product term or visible behavior | `CONTEXT.md`, both ARB files, and `api/docs/openapi.yaml` when externally visible |

## Done means

- `cd api && go test ./... && go build ./...` passes.
- `cd app && flutter analyze && flutter test && flutter build web` passes.
- `docker compose config --quiet` passes when Docker Compose or environment defaults change.

## Never merges without a human

A person has to have **read this diff** before it lands. Telling an agent "merge it when you're done" is
approving a goal, not this change — so it does not count for anything on this list. Everywhere else it counts
fine, which is the point of having a list.

- Any diff touching `api/internal/infrastructure/mysql/schema_migration.go`, `api/internal/infrastructure/mysql/discipline_migration.go`, or `api/internal/infrastructure/mysql/concurso_schema.go`.
