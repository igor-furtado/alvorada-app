# UX Writing em pt-BR

## Regra

Escreva como orientadora serena: voz ativa, ação concreta, explicação curta e vocabulário do `CONTEXT.md`. A mensagem informa o ocorrido e o próximo passo; não culpa, cobra ou gamifica.

| Tipo | Estrutura | Certo | Errado |
|---|---|---|---|
| Erro | ocorrido + resolução | “Não foi possível salvar. Tente novamente; seus dados foram preservados.” | “Erro 500.” |
| Sucesso | resultado concluído | “Horizonte criado.” | “Sucesso!” |
| Aviso | condição + consequência | “Há alterações não salvas. Se sair, elas serão perdidas.” | “Atenção!” |
| Confirmação | ação + objeto + impacto | “Excluir Horizonte? O Edital também será removido.” | “Tem certeza?” |
| Vazio | motivo + ação | “Nenhum Horizonte ativo. Crie o primeiro Horizonte.” | “Sem dados.” |
| Loading | ação em andamento | “Salvando alterações…” | “Aguarde.” |

## Convenções

- Botão: verbo + objeto; exemplo: “Salvar alterações”.
- Título: uma linha. Descrição: até duas frases. Snackbar: uma frase e uma ação.
- Placeholder mostra formato; label permanece visível; tooltip nomeia ação e atalho.
- Capitalização de frase. Ponto somente em frases.
- Data: `8 nov. 2026`; número: `1.234`; percentual: `80%`; interface funcional sem emoji.
- Menu: Hoje, Semana, Horizontes, Revisões, Caderno.
- Conteúdo: Alvorada do dia, Esta semana, Horizonte, Edital, Revisão programada, Caderno de Erros.
- `excluir`: irreversível; `remover`: reversível; `salvar`: persistir; `concluir`: encerrar atividade.

## Código e aceite

Texto funcional vive em `AppMessages`; nome, assinatura e assets, em `AppBrand`; conteúdo demonstrativo permanece no modelo da feature.

Conclua quando a mensagem oferece próximo passo, usa o termo canônico e não introduz literal funcional em widget compartilhado.
