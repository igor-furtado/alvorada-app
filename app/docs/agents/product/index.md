# Produto

Use esta documentação ao alterar comportamento, priorização, método, descanso, métricas ou navegação do produto.

- Para regras e invariantes do produto, leia [rules.md](rules.md).
- Para conceitos e termos canônicos do domínio, leia `CONTEXT.md` e siga `docs/agents/domain.md`.
- Para o estado de uma migração que afete o produto, leia `docs/brand/prumo-rebrand-plan.md`.

## Hierarquia

1. `CONTEXT.md` define o significado e o nome atual dos conceitos.
2. [rules.md](rules.md) define comportamentos que a implementação deve preservar.
3. O Design System define a apresentação e a interação genérica dos fluxos.

Uma proposta terminológica só entra nestes documentos depois de aprovada e coordenada com modelos, rotas, APIs, testes e contratos afetados.

## Processo de mudança

1. Identifique as regras e os conceitos afetados.
2. Verifique decisões relacionadas em `CONTEXT.md` e nos ADRs.
3. Atualize a regra de negócio antes ou junto da implementação que a altera.
4. Mantenha testes e contratos coerentes com a decisão.

Conclua quando todas as regras afetadas estão explícitas e documentação, implementação e testes descrevem o mesmo comportamento.
