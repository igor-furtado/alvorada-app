# Arquitetura Flutter

Use ao alterar `domain` ou `data`. Siga o [guia oficial do Flutter](https://docs.flutter.dev/app-architecture/guide#data-layer).

## Roteamento

- Entidades, invariantes, inputs, contratos de repository ou use cases: leia [domain.md](domain.md).
- API models, serialização, services, repositories concretos, cache ou HTTP: leia [data.md](data.md).
- Mudanças entre camadas: leia ambos antes de editar.

## Convenções comuns

```text
presentation → domain ← data → fonte externa
```

`presentation` consome `domain`; `data` converte formatos externos para `domain`.

Use negócio em português sem acentos e qualificadores técnicos em inglês: `Disciplina`, `DisciplinaApiModel`, `DisciplinasRepository`, `CreateDisciplinaUseCase`. Aplique o mesmo vocabulário a pastas e arquivos: `features/disciplinas`, `disciplina_api_model.dart`.

Conclua com fronteiras e nomes corretos, `flutter analyze` e testes afetados verdes.
