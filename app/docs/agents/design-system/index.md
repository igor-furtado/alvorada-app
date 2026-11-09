# Design System

## Fundamentos

Base visual: o produto usa a gramática de **shadcn/ui** adaptada à identidade mineral do Prumo.app. Leia [shadcn.md](shadcn.md) antes de criar, alterar ou revisar qualquer componente ou tela.

Tema: `AppShadTheme` é a fonte de verdade dos componentes shadcn. `AppTheme` é a ponte para infraestrutura Material e deve espelhar os mesmos papéis. Use `colorScheme`/`textTheme`, `context.tokens` e `AppIcons`; widgets não acessam primitivos.

Token ausente: nomeie pela intenção, atualize `copyWith`/`lerp` e exporte. Ícone novo usa Phosphor Light e entra em `app_icons_test.dart`.

## Componentes

Composição: importe `core/ui/app_ui.dart` e reutilize o UI Kit. O código de feature consome `App*`; somente o UI Kit instancia `Shad*`. Átomos são independentes; moléculas usam átomos; organismos usam átomos/moléculas; templates podem usar os níveis anteriores.

API: parâmetros nomeados, construtor `const`, variantes/estados explícitos e callback nulo para desabilitar. Componente novo usa tema/tokens, entra no barrel do nível e testa sua API pública.

Migração: ao tocar uma superfície que ainda usa controle Material bruto, substitua o controle pelo equivalente `App*`. Material permanece apenas como infraestrutura de navegação, layout ou acessibilidade quando não há equivalente shadcn; a exceção fica encapsulada no UI Kit e visualmente alinhada em `AppTheme`.

## Comportamento

Leia somente a referência correspondente à mudança:

- Formulário, lista, estado, feedback, ação destrutiva ou navegação: [interaction.md](interaction.md)
- Texto visível: [writing.md](writing.md)
- Layout adaptativo ou navegação por largura: [responsive.md](responsive.md)
- Cor, semântica, foco, teclado, toque, texto ampliado ou movimento: [accessibility.md](accessibility.md)

Plataforma: Web responsiva, orientação livre e idioma pt-BR.

Conclua em `app/`: o checklist de [shadcn.md](shadcn.md) está atendido, `dart format lib test`, `flutter analyze` e `flutter test` passam.
