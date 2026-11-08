# Flutter Design System

Ao criar ou alterar widgets, derive atributos visuais do tema pelo `BuildContext`. Importe `core/theme/app_theme.dart`; widgets não importam `tokens/primitives/`.

## Roteamento

- cores e texto Material: `Theme.of(context).colorScheme` e `.textTheme`;
- cores próprias: `context.tokens.colors`;
- margens, paddings, gaps e offsets: `context.tokens.spacing`;
- dimensões de componentes: `context.tokens.sizes`;
- breakpoints e limites: `context.tokens.layout`;
- raios e espessuras: `context.tokens.borders`;
- glifos e tamanhos: `AppIcons` e `context.tokens.icons`;
- opacidade, sombras e animação: `opacity`, `elevations` e `motion`.

Isso cobre `EdgeInsets`, `SizedBox`, `Container`, `Wrap`, `Positioned`, constraints, bordas, ícones, indicadores e `LayoutBuilder`. Números de conteúdo, como contagens e progresso calculado, permanecem locais.

Valores do contexto não são constantes: remova `const` somente do ancestral dependente e preserve-o nos filhos independentes.

## Token ausente

1. Escolha a categoria pela intenção; coincidência de valor não implica reuso.
2. Adicione nome semântico (`dialogWide`, não `size560`), campo, padrão e `lerp`.
3. Para categoria nova, atualize `AppTokens`, `copyWith`, `lerp` e `tokens.dart`.
4. Para glifo novo, use Phosphor Light em `AppIcons` e cubra-o em `app_icons_test.dart`.

## Conclusão

Em `app/`, execute `dart format lib test`, `flutter analyze` e `flutter test`. Revise o diff: cada atributo visual deve vir do tema ou de `context.tokens`, sem primitivos, `Icons.*` ou escala estática intermediária.
