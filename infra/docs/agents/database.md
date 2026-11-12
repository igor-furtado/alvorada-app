# Banco de dados

## Processo

1. Leia `CONTEXT.md`, regras de produto e ADRs; identifique entidades, relações e invariantes afetadas.
2. Atualize o esquema de instalação limpa e todas as consultas.
3. Para bancos existentes, crie migração idempotente e retomável que preserve dados.
4. Proteja nulabilidade, intervalos, unicidade e referências no banco; use transação para gravações que precisam existir juntas.
5. Teste instalação, migração e CRUD/ordenação do repository.

## Nomenclatura

- Português sem acentos e `snake_case`.
- Tabelas no plural: `concursos`, `disciplinas`, `topicos`, `concursos_topicos`.
- Colunas: `nome`, `dificuldade`, `cor`, `posicao`, `criado_em`, `atualizado_em`.
- PK `id`; FK `<entidade>_id`, como `disciplina_id`.
- `idx_<tabela>_<finalidade>`, `fk_<origem>_<destino>`, `chk_<tabela>_<regra>`.

Inglês aparece apenas no mapeamento da migração legada. Esquema ativo, SQL do repository e instalação usam português.

## Integridade e migração

- Defina `ON DELETE` explicitamente e ordene consultas com desempate estável.
- Em renomes, detecte o esquema, aplique DDL incremental e execute backfills idempotentes antes de servir requisições.
- Teste esquema legado, atual e colisão; valide em MySQL real quando disponível.

## Conclusão

- Instalação e migração convergem para o mesmo esquema.
- Nenhuma tabela ou coluna ativa de negócio permanece em inglês.
- Invariantes afetadas têm proteção e teste; testes da API passam.
