# Design system Flutter

Use este guia ao criar ou alterar componente `App*`, token, tema, ícone, primitivo responsivo, interação visual ou contrato de acessibilidade. Para páginas, rotas, Bloc e estado de interface, siga [presentation.md](presentation.md).

## Fontes de verdade

Consulte nesta ordem:

1. `lib/core/design_system/design_system.dart`, única interface pública consumida pelas features;
2. implementação e testes em `lib/core/design_system/` e `test/core/design_system/`;
3. tokens acessíveis por `context.tokens` e `AppIcons`;
4. `features/disciplinas/presentation`, referência de composição dos componentes em uma feature;
5. shadcn/ui Base UI atual, quando existir componente equivalente.

O código do repositório decide APIs e tokens existentes. A referência externa decide anatomia e comportamento que ainda precisam ser modelados.

Conclua o inventário quando cada requisito resultar em reutilizar, estender ou criar um `App*`, sem duplicar uma composição pública existente.

## Organização por responsabilidade

```text
design_system/
├── controls/    ações, entradas, seleção e navegação local
├── feedback/    estado, progresso e mensagens
├── overlays/    superfícies temporárias
└── layout/      composição, responsividade e superfícies estruturais
```

- `controls` contém widgets operáveis e suas composições de formulário.
- `feedback` comunica loading, progresso, resultado e estado remoto.
- `overlays` coordena foco, scrim, teclado e fechamento de drawers e diálogos.
- `layout` organiza conteúdo sem conhecer regra de feature.
- Features importam somente `core/design_system/design_system.dart`; detalhes Material ficam encapsulados em `App*`.
- Arquivos internos importam a implementação direta de que dependem, sem atravessar o barrel público.

Um componente público usa prefixo `App`, parâmetros nomeados, construtor `const` quando possível, variantes e tamanhos tipados e callback nulo para indisponibilidade. Conceitos com efeitos diferentes mantêm APIs distintas: `AppAlertDialog` confirma uma decisão e `AppDrawer` executa uma tarefa lateral.

Publique somente variantes consumidas pelo produto. Estados usados apenas por testes ou exemplos não justificam ampliar a interface; o teste deve atravessar o mesmo contrato usado pelas features.

Conclua quando a API expressar anatomia, conteúdo, variantes, tamanhos e estados sem exigir que a feature conheça a implementação interna.

## Processo

### 1. Modele o contrato

Inspecione todas as composições e estados aplicáveis da referência: default, hover, focus, pressed, disabled, loading e erro. Inclua teclado, ponteiro, semântica, overlay e retorno de foco.

Prefira ampliar uma API existente quando o novo caso conserva o mesmo papel. Crie outro componente quando o papel, a semântica ou o efeito para a pessoa mudar.

Conclua quando cada estado e interação tiver representação explícita na API ou uma composição documentada do componente.

### 2. Implemente com tokens

Use somente papéis semânticos:

- `context.tokens.colors`, `typography`, `spacing`, `borders`, `motion`, `icons` e `opacity`;
- `context.tokens.layout` para dimensões estruturais compartilhadas;
- `context.tokens.overlayShadow`, `overlayBackdropBlur`, `feedbackIconSize` e `listItemMediaHeight` para decisões transversais sem família própria;
- `context.tokens.opacity` e `motion` para transparência e movimento;
- `AppIcons` para glifos Lucide;
- `context.motionDuration` para respeitar redução de movimento.

Um token novo descreve intenção, participa de `lerp` e recebe teste quando cria contrato visual. Valores locais continuam aceitáveis somente quando pertencem ao dado ou à geometria interna sem significado compartilhado.

Todo texto usa a tipografia Geist por meio de estilo semântico ou herança deliberada. Componentes públicos definem sua aparência com tokens, mantendo `Theme.of(context)` apenas para estado de plataforma que o contrato de tema já controla.

Conclua quando temas claro e escuro usam os mesmos papéis, mudanças de estado preservam dimensões e nenhum literal substitui um token existente.

### 3. Publique o componente

Para um `App*` público:

1. coloque a implementação na responsabilidade adequada;
2. exporte somente em `design_system.dart`;
3. adicione teste da interface pública e das interações relevantes.

Conclua quando uma feature conseguir importar apenas `design_system.dart` e o teste exercitar o contrato completo.

### 4. Compare visualmente

Compare referência e implementação nos temas claro e escuro e nas larguras afetadas. Verifique tipografia, cor, espaçamento, dimensão, alinhamento, ícone, borda, raio, overlay, foco e movimento.

Conclua quando toda divergência observada for corrigida ou registrada como decisão intencional do produto.

## Gramática visual

| Aspecto | Contrato |
| --- | --- |
| Cor | Papéis de `AppTokens`; base neutra zinc nos temas claro e escuro. |
| Tipografia | Geist; hierarquia por tamanho, peso e espaçamento. |
| Superfície | `canvas`, `surface`, `card` e `popover` seguem o papel do conteúdo. |
| Borda | Separador padrão de 1 px; foco usa ring perceptível. |
| Raio | Controles usam raio discreto; cards e overlays podem usar o nível seguinte. |
| Sombra | Apenas overlays e popovers usam `tokens.overlayShadow`. |
| Ícone | Somente `AppIcons`; ícone decorativo fica fora da árvore semântica. |
| Movimento | Duração semântica; redução de movimento produz duração zero. |
| Densidade | Controles compactos preservam alvo interativo mínimo de 24×24 px. |

## Padrões de interação

| Padrão | Composição | Aceite observável |
| --- | --- | --- |
| Formulário | `AppForm` organiza os campos dentro de `AppDrawer`; todo drawer apresenta título e subtítulo, a ação primária envia e o X do cabeçalho cancela. | Clique no scrim fecha quando ocioso; clique no fundo interno apenas remove o foco; X ou Esc fecha quando ocioso; primeiro erro recebe foco; loading bloqueia repetição e fechamento. |
| Destrutiva | `AppAlertDialog` nomeia ação, objeto e impacto. | Esc cancela; fechar devolve foco; confirmação é inequívoca. |
| Estado remoto | `AppSkeleton`, `AppStateView` e conteúdo preservado durante refresh. | Retry mantém contexto; loading inicial conserva a estrutura. |
| Feedback | Inline corrige campo; toast informa resultado transitório; estado persistente permanece na página. | Mudança dinâmica é anunciada uma vez. |
| Overlay | Drawer para tarefa; dialog para conteúdo; alert dialog para decisão. | Scrim, foco, teclado e gesto de saída seguem o mesmo contrato. |

## Responsividade

Meça a janela com `MediaQuery.sizeOf` e o espaço local com `LayoutBuilder`. Use `context.windowClass`, `ResponsiveBuilder` e os breakpoints de `AppLayoutTokens`.

| Classe | Largura |
| --- | ---: |
| compact | `< 600` |
| medium | `600–839` |
| expanded | `840–1199` |
| large | `≥ 1200` |

Reorganize antes de ocultar. Quebre texto antes de truncar. Formulários usam uma coluna no compacto e agrupamentos relacionados nas demais larguras. Safe area e `viewInsets` protegem recorte e teclado. Redimensionar preserva foco, estado e rolagem.

- `AppPage` é dono do cabeçalho, das margens e do reflow entre título e ação.
- `AppMasterDetail` decide entre empilhamento e painéis redimensionáveis.
- `AppListItem` reposiciona seu `trailing` quando largura ou escala de texto exigirem.
- Componentes auxiliares usados apenas por outro `App*` permanecem fora do barrel público.

Aceite nas larguras 390, 720, 1024 e 1440 px, em orientação livre e com texto a 200%. Conclua quando ações essenciais permanecerem visíveis e nenhum componente declarar breakpoint literal.

## Acessibilidade

WCAG 2.2 AA bloqueia a entrega.

- Texto comum atende 4,5:1; texto grande, foco e componentes atendem 3:1.
- Tab segue a ordem visual; setas percorrem grupos; Esc fecha superfície temporária.
- Todo ícone acionável tem nome; label e controle formam uma unidade semântica.
- Erro, loading, feedback e novo conteúdo são anunciados uma vez.
- Foco é visível e não depende somente de cor.
- Status combina texto ou ícone com cor.
- Texto a 200% reorganiza sem overflow.

Conclua quando testes de `Semantics` encontram nome, papel, estado e ação e o componente permanece operável somente por teclado.

## Texto visível

Use voz ativa, ação concreta e explicação curta. Botões usam verbo + objeto; títulos ocupam uma linha; descrições usam até duas frases. Placeholder mostra formato e label permanece visível. Texto genérico compartilhado é obtido por `context.l10n` a partir dos ARBs em `lib/l10n`; conteúdo sem consumidor real não permanece no produto.

Não declare texto visível como valor padrão `const` de componente. Use parâmetro anulável e resolva o padrão localizado durante `build`. Parâmetros dinâmicos e quantidades usam placeholders e plurals ICU no ARB.

| Tipo | Estrutura |
| --- | --- |
| Erro | ocorrido + resolução |
| Sucesso | resultado concluído |
| Aviso | condição + consequência |
| Confirmação | ação + objeto + impacto |
| Vazio | motivo + próxima ação |
| Loading | ação em andamento |

## Verificação

Em `app/`, execute:

```bash
dart format lib test
flutter analyze
flutter test
flutter build web
```

Conclua quando os testes, a comparação visual e os quatro comandos confirmarem o mesmo contrato.
