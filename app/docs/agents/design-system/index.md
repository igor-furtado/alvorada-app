# Design System

## Fundamentos

Visual: importe `core/theme/app_theme.dart`. Use `colorScheme`/`textTheme`, `context.tokens` e `AppIcons`; widgets não acessam primitivos.

Token ausente: nomeie pela intenção, atualize `copyWith`/`lerp` e exporte. Ícone novo usa Phosphor Light e entra em `app_icons_test.dart`.

## Componentes

Composição: importe `core/ui/app_ui.dart` e reutilize o UI Kit. Átomos são independentes; moléculas usam átomos; organismos usam átomos/moléculas; templates podem usar os níveis anteriores.

API: parâmetros nomeados, construtor `const`, variantes/estados explícitos e callback nulo para desabilitar. Componente novo usa tema/tokens, entra no barrel do nível e testa sua API pública.

## Comportamento

Leia somente a referência correspondente à mudança:

- Formulário, lista, estado, feedback, ação destrutiva ou navegação: [interaction.md](interaction.md)
- Texto visível: [writing.md](writing.md)
- Layout adaptativo ou navegação por largura: [responsive.md](responsive.md)
- Cor, semântica, foco, teclado, toque, texto ampliado ou movimento: [accessibility.md](accessibility.md)

Plataforma: Web responsiva, orientação livre e idioma pt-BR.

Conclua em `app/`: `dart format lib test`, `flutter analyze` e `flutter test` passam.
