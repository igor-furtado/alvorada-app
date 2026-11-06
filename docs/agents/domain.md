# Domain Docs

Como as skills de engenharia devem consumir a documentação de domínio ao explorar o projeto.

## Antes de explorar

- Leia `CONTEXT.md` na raiz do repositório.
- Se `CONTEXT-MAP.md` existir no futuro, use-o para encontrar os contextos relevantes.
- Leia os ADRs em `docs/adr/` relacionados à área que será modificada.

Se algum desses arquivos não existir, prossiga silenciosamente. A ausência não deve bloquear o trabalho nem provocar a criação prematura de documentação.

## Estrutura

Este é um repositório **single-context**:

```text
/
├── CONTEXT.md
├── docs/adr/
├── app/
└── api/
```

## Use o vocabulário do glossário

Ao nomear conceitos em issues, propostas, testes e código, use os termos definidos no glossário de `CONTEXT.md`. Não introduza sinônimos para conceitos já estabelecidos.

Quando um conceito necessário não estiver documentado, avalie se o termo é inadequado ou se existe uma lacuna real no modelo de domínio. Lacunas reais devem ser tratadas com a skill de modelagem de domínio.

## Sinalize conflitos com ADRs

Quando uma proposta contrariar uma decisão registrada, destaque explicitamente o conflito em vez de sobrescrever a decisão silenciosamente:

> Contradiz ADR-0007 — vale reabrir a decisão porque…
