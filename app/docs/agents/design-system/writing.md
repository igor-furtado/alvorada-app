# UX Writing em pt-BR

## Regra

Use voz ativa, ação concreta e explicação curta. A mensagem informa o ocorrido e o próximo passo.

| Tipo | Estrutura | Certo | Errado |
|---|---|---|---|
| Erro | ocorrido + resolução | “Não foi possível salvar. Tente novamente; seus dados foram preservados.” | “Erro 500.” |
| Sucesso | resultado concluído | “Registro criado.” | “Sucesso!” |
| Aviso | condição + consequência | “Há alterações não salvas. Se sair, elas serão perdidas.” | “Atenção!” |
| Confirmação | ação + objeto + impacto | “Excluir registro? Os dados associados também serão removidos.” | “Tem certeza?” |
| Vazio | motivo + ação | “Nenhum registro disponível. Crie o primeiro.” | “Sem dados.” |
| Loading | ação em andamento | “Salvando alterações…” | “Aguarde.” |

## Convenções

- Botão: verbo + objeto; exemplo: “Salvar alterações”.
- Título: uma linha. Descrição: até duas frases. Snackbar: uma frase e uma ação.
- Placeholder mostra formato; label permanece visível; tooltip nomeia ação e atalho.
- Capitalização de frase. Ponto somente em frases.
- Data: `8 nov. 2026`; número: `1.234`; percentual: `80%`; interface funcional sem emoji.
- `excluir`: irreversível; `remover`: reversível; `salvar`: persistir; `concluir`: encerrar atividade.

## Código e aceite

Texto funcional vive em `AppMessages`; conteúdo demonstrativo permanece no modelo da feature.

Conclua quando a mensagem oferece próximo passo e não introduz literal funcional em widget compartilhado.
