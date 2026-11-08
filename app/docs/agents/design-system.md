# Design System

## Fundamentos

- Importe `core/theme/app_theme.dart`; não importe `tokens/primitives/` em widgets.
- Use `Theme.of(context).colorScheme` e `.textTheme` para Material.
- Use `context.tokens`: `colors`, `spacing`, `sizes`, `layout`, `borders`, `icons`, `opacity`, `elevations` e `motion`.
- Use apenas `AppIcons`. Números de conteúdo e cálculos permanecem locais.
- Token ausente: crie um nome pela intenção, atualize `copyWith`/`lerp` e exporte-o. Ícones novos usam Phosphor Light e teste em `app_icons_test.dart`.

## Componentes

- Importe `core/ui/app_ui.dart` e reutilize o UI Kit antes de criar widgets locais.
- Dependências: átomos → nenhum componente; moléculas → átomos; organismos → átomos/moléculas; templates → níveis anteriores.
- Componentes usam somente tema e `context.tokens`; nunca valores visuais literais.
- APIs têm parâmetros nomeados, construtores `const`, variantes/estados explícitos e callback nulo para desabilitar.
- Garanta semântica, foco por teclado, escala de texto e toque mínimo definido pelos tokens.
- Ao adicionar componente, exporte-o no barrel do nível e teste sua API pública.

Valide em `app/`: `dart format lib test`, `flutter analyze` e `flutter test`.
