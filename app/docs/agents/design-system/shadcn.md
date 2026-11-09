# Convenção shadcn/ui

## Hierarquia

1. shadcn/ui define composição, variantes, estados, densidade, bordas e elevação.
2. A identidade do Prumo.app define paleta, tipografia editorial, iconografia e voz.
3. Acessibilidade e responsividade definem limites obrigatórios de interação.

Quando houver tensão, preserve o comportamento shadcn e aplique a marca por tokens. O resultado esperado é shadcn reconhecível com identidade Prumo.app, não uma cópia da paleta neutra do site de referência.

## Arquitetura

- `AppShadTheme` traduz tokens semânticos para `ShadColorScheme` e configura o pacote `shadcn_ui`.
- `AppTheme` mantém Material, navegação e widgets sem equivalente no mesmo sistema visual.
- `App*` é a API pública do produto. Features importam `core/ui/app_ui.dart`; `Shad*` fica encapsulado no UI Kit.
- Tokens expressam intenção. Valores visuais não entram diretamente em widgets de feature.

Use esta ordem ao implementar:

1. Procure um componente `App*` existente.
2. Se faltar comportamento, estenda a API do componente semântico existente.
3. Se faltar um componente, crie um wrapper `App*` sobre o equivalente `Shad*`, exporte no barrel e teste a API pública.
4. Use Material somente quando shadcn não oferecer o papel necessário. Encapsule a exceção em `App*` e derive o visual de `AppTheme`/tokens.

## Gramática visual

| Aspecto | Regra |
| --- | --- |
| Cor | Use `background`, `card`, `popover`, `muted`, `accent`, `destructive`, `border`, `input` e `ring` pelo papel equivalente em `AppShadTheme`. |
| Raio | Base de 6 dp. Controles e cards usam raio pequeno; cápsula fica restrita a estados que semanticamente pedem formato circular. |
| Borda | 1 dp semântica é o padrão de separação. Foco usa `ring` de 2 dp. |
| Elevação | Superfícies são planas e delimitadas por borda. Sombra é discreta e reservada a overlay/popover. |
| Densidade | Controles mantêm a proporção compacta de shadcn dentro de alvo interativo mínimo de 48×48 dp. |
| Tipografia | Inter em controles e rótulos. Fraunces e Newsreader continuam em títulos e leitura conforme a marca. |
| Ícone | Use `AppIcons`/Phosphor Light; tamanho padrão 16–20 dp. Ícone decorativo sai da árvore semântica. |
| Movimento | Transições curtas e funcionais; `context.motionDuration` zera com redução de movimento. |

## Mapeamento de componentes

| Papel | API do produto | Base visual |
| --- | --- | --- |
| Ação | `AppButton` | `ShadButton` e variantes primary, secondary, outline, ghost e destructive |
| Entrada | `AppTextInput`, `AppFormField` | `ShadInputFormField` |
| Seleção booleana | `AppCheckbox`, `AppSwitch` | `ShadCheckbox`, `ShadSwitch` |
| Escolha única | `AppRadio`, `AppRadioGroup` | `ShadRadio`, `ShadRadioGroup` |
| Estado curto | `AppBadge` | `ShadBadge` |
| Superfície agrupada | `AppCard` | `ShadCard` |
| Separação | `AppDivider` | `ShadSeparator` |
| Menu de ações | `AppMenuButton` | `ShadPopover`, `ShadContextMenuItem` |
| Decisão modal | `AppDialog` | `ShadDialog`; tela cheia no compacto |
| Filtro | `AppChip` | exceção encapsulada e tematizada até existir equivalente no pacote |
| Feedback transitório | `AppSnackbar` | exceção encapsulada e tematizada; preserve anúncio acessível |
| Navegação | `AppShell` | infraestrutura Material com tokens shadcn |

O nome do wrapper representa o papel no produto; não replique o nome técnico do pacote quando o conceito já existir no domínio do UI Kit.

## Estados

Todo componente interativo cobre default, hover, focus, pressed e disabled. Componentes de formulário também cobrem erro; ações assíncronas cobrem loading. Use callback nulo como estado desabilitado e preserve a dimensão entre estados.

- Hover usa `muted` ou `accent` sem deslocar layout.
- Focus usa `ring`, nunca apenas mudança de cor de fundo.
- Disabled reduz ênfase sem perder contraste de leitura.
- Error usa `destructive` em borda, texto e semântica; o dado digitado permanece.
- Loading mantém o rótulo e bloqueia submissão duplicada.

## Critério de aceite

Uma mudança de UI está concluída quando:

- a feature usa somente APIs `App*` para controles cobertos pelo mapeamento;
- claro e escuro compartilham a mesma hierarquia, bordas e estados;
- não há raio, cor, sombra, espaçamento ou duração literal no widget de feature;
- foco, teclado, semântica, toque de 48 dp e texto a 200% continuam válidos;
- o teste público do componente confirma a base `Shad*` e pelo menos um estado relevante;
- exceções Material estão encapsuladas, justificadas pela ausência de equivalente e alinhadas pelo tema;
- formatação, análise estática e todos os testes passam.
