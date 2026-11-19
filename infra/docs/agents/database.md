# Banco de dados

## Processo

1. Leia `CONTEXT.md`, regras de produto e ADRs; identifique entidades, relações e invariantes afetadas.
2. Atualize o esquema de instalação limpa e todas as consultas.
3. Para bancos existentes, crie migração idempotente e retomável que preserve dados.
4. Proteja nulabilidade, intervalos, unicidade e referências no banco; use transação para gravações que precisam existir juntas.
5. Teste instalação, migração e CRUD/ordenação do repository.

## Nomenclatura

- Português sem acentos e `snake_case`.
- Tabelas no plural: `concursos`, `disciplinas`, `topicos`, `concursos_topicos`, `concursos_disciplinas`.
- Colunas: `nome`, `dificuldade`, `cor`, `posicao`, `criado_em`, `atualizado_em`.
- PK `id`; FK `<entidade>_id`, como `disciplina_id`.
- `idx_<tabela>_<finalidade>`, `fk_<origem>_<destino>`, `chk_<tabela>_<regra>`.

Inglês aparece apenas no mapeamento da migração legada. Esquema ativo, SQL do repository e instalação usam português.

## Integridade e migração

- Defina `ON DELETE` explicitamente e ordene consultas com desempate estável.
- O peso de uma Disciplina é específico de cada Edital e vive em `concursos_disciplinas.peso` como decimal positivo e anulável.
- A ordem das Disciplinas vive em `disciplinas.posicao`; reordenações atualizam a lista completa em uma única transação e novas Disciplinas entram no final.
- A ordem dos Tópicos editáveis de uma Disciplina vive em `topicos.posicao`; reordenações atualizam a lista completa em uma única transação. Revisão de Véspera é ordenada separadamente e permanece por último.
- `concursos_topicos` preserva o estado do estudo específico daquele Concurso: teoria, memória, conferência, acertos, erros, versão da metodologia e planejamento inicial. Remover um Tópico do Edital preenche `removido_em`; não apaga o progresso.
- `concursos_topicos.concluido` é derivado de teoria, memória e conferência. Questões calculam desempenho e não bloqueiam a conclusão.
- O cronômetro do modo foco é exclusivamente visual e não possui persistência.
- Revisões opcionais vivem em `revisoes_programadas`, com intervalos limitados a D+1, D+7 e D+30. A unicidade por Concurso–Tópico–intervalo torna a gravação idempotente.
- O planejamento semanal combina `concursos_topicos.data_planejada` com `revisoes_programadas.data_planejada`; não existe uma tabela materializada da semana.
- Em renomes, detecte o esquema, aplique DDL incremental e execute backfills idempotentes antes de servir requisições.
- Teste esquema legado, atual e colisão; valide em MySQL real quando disponível.

## Conclusão

- Instalação e migração convergem para o mesmo esquema.
- Nenhuma tabela ou coluna ativa de negócio permanece em inglês.
- Invariantes afetadas têm proteção e teste; testes da API passam.
