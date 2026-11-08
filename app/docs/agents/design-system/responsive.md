# Responsividade Web

## Classes

Meça a janela com `MediaQuery.sizeOf`; meça espaço local com `LayoutBuilder`.

| Classe | Largura | Navegação |
|---|---:|---|
| compact | `< 600` | `NavigationBar` |
| medium | `600–839` | `NavigationRail` |
| expanded | `840–1199` | sidebar |
| large | `≥ 1200` | sidebar |

Use `context.windowClass`, `ResponsiveBuilder` e `ResponsiveValue<T>`. Breakpoint local só representa quebra demonstrada pelo componente e vive em `AppLayoutTokens`.

## Adaptação

| Elemento | Compact | Demais |
|---|---|---|
| Dialog | tela inteira | centralizado, largura máxima |
| Formulário | uma coluna | até duas colunas relacionadas |
| Dados | cards quando preservam hierarquia | tabela quando comparação importa |
| Ações | ocupam/quebram na largura | alinham ao fim |

Reorganize antes de esconder; quebre texto antes de truncar; reserve scroll horizontal para comparação tabular. Safe area e `viewInsets` protegem recorte e teclado.

## Aceite

- Testes em 390, 720, 1024 e 1440 px, orientação livre e texto a 200%.
- Redimensionamento preserva foco, estado e rolagem.
- Ações essenciais permanecem visíveis.
- Widget não contém breakpoint literal.
