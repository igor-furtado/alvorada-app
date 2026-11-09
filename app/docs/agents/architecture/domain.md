# Camada domain

## Processo

1. Leia `CONTEXT.md`, `docs/agents/domain.md`, regras de produto e ADRs relacionados; liste conceitos e invariantes afetados.
2. Modele entidades imutáveis. Copie coleções para estruturas não modificáveis e rejeite estados inválidos na construção ou em tipos dedicados.
3. Use inputs quando uma operação tiver vários dados, opcionais ou padrões.
4. Defina contratos de `Repository` somente com tipos de `domain` e Dart; implemente-os em `data`.
5. Crie `UseCase` apenas para lógica reutilizada, complexa ou que combine dependências.
6. Teste invariantes, padrões, normalização e falhas.

## Fronteira

- `domain` importa apenas Dart e `domain`.
- Regras de estado válido ficam em `domain`; JSON, HTTP, banco, cache, widgets e formatos externos ficam fora.
- Use cases dependem de contratos; contratos permanecem substituíveis por fakes.

## Conclusão

- Nenhuma dependência de Flutter, `data` ou infraestrutura.
- Todo estado inválido conhecido possui teste.
- Nomes seguem [index.md](index.md) e o glossário.
