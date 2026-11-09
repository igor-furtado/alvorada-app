# Padrões de interação

| Padrão | Quando / quando não | Regra | Código | Aceite |
|---|---|---|---|---|
| Formulário | Entrada editável; não em ação direta | Formato durante escrita; conteúdo ao sair; tudo no envio. Erro preserva dados, foca e anuncia o primeiro campo. Envio bloqueia repetição. Edição oferece salvar/cancelar e protege abandono. | `AppValidatedForm`, `AppFormField`, `AppButton` | Tab segue ordem visual; Enter não duplica envio; falha preserva valores. |
| Lista remota | Fonte persistida; não em dados demonstrativos locais | Skeleton inicial; busca, filtro, ordem e consulta na URL; scroll infinito antecipado. Novo lote preserva foco. Erro no rodapé mantém itens; fim e quantidade são anunciados. Atualização é explícita. | `AppInfiniteListView`, `AppSearchField`, `AppChip`, `AppStateView` | Troca de branch preserva scroll; filtro reinicia cursor; retry continua a página atual. |
| Destrutiva | Undo para reversível; dialog para irreversível/cascata | Reversível executa e oferece “Desfazer”. Irreversível nomeia ação, objeto e impacto antes de confirmar. | `AppSnackbar`, `AppDialog`, `AppButtonVariant.destructive` | Esc cancela; foco retorna ao acionador; undo restaura item e posição. |
| Feedback | Inline para correção local; snackbar para resultado transitório; banner para condição persistente; dialog para decisão | Skeleton mantém a estrutura; spinner representa operação curta; vazio explica e oferece uma ação; erro oferece recuperação; offline preserva dados. | `AppStateView`, `AppSkeleton`, `AppLoadingIndicator`, `AppSnackbar`, `AppDialog` | Mudança dinâmica é anunciada uma vez; loading mantém conteúdo útil. |
| Navegação | Toda troca entre áreas ou tela interna | `StatefulShellRoute.indexedStack` mantém uma branch por área. Deep link abre a branch correta; destino ativo volta à raiz. Tela interna usa voltar/breadcrumb. | `AppShell`, `AppPageTemplate`, `go_router` | URL representa a tela; branch preserva scroll, filtros, formulário e histórico. |

## Exemplos de decisão

- Certo: “Excluir registro? Os dados associados também serão removidos.”
- Errado: “Tem certeza?”.
- Certo: falha da próxima página mantém os itens e mostra “Tentar novamente” no rodapé.
- Errado: falha limpa a lista ou abre dialog.
