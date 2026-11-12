# Design system Flutter

Use este guia ao criar ou alterar componente `App*`, token, tema, ícone, primitivo responsivo, interação visual ou contrato de acessibilidade. Para páginas, rotas, Bloc e estado de interface, siga [presentation.md](presentation.md).

## Fontes de verdade

Consulte nesta ordem:

1. `lib/src/core/ui/app_ui.dart`, API pública consumida pelas features;
2. implementação e testes do componente em `lib/src/core/ui/`;
3. tokens acessíveis por `context.tokens` e `AppIcons`;
4. `AppComponentRegistry` e o catálogo em `features/design_system`;
5. `features/disciplinas/presentation`, referência de composição dos componentes em uma feature;
6. shadcn/ui Base UI atual, quando existir componente equivalente.

O código do repositório decide APIs e tokens existentes. A referência externa decide anatomia e comportamento que ainda precisam ser modelados.

Conclua o inventário quando cada requisito resultar em reutilizar, estender ou criar um `App*`, sem duplicar uma composição pública existente.

## Arquitetura de componentes

```text
atoms → molecules → organisms → templates → feature
```

- Átomos não dependem de composições superiores.
- Moléculas combinam átomos em um controle ou unidade de conteúdo.
- Organismos coordenam moléculas e superfícies interativas.
- Templates organizam páginas sem conhecer regras de uma feature.
- Features importam `core/ui/app_ui.dart`; detalhes Material ficam encapsulados em `App*`.

Um componente público usa prefixo `App`, parâmetros nomeados, construtor `const` quando possível, variantes e tamanhos tipados e callback nulo para indisponibilidade. Conceitos com efeitos diferentes mantêm APIs distintas: `AppAlertDialog` confirma uma decisão; `AppDialog` apresenta conteúdo; `AppDrawer` executa uma tarefa lateral ou inferior.

Conclua quando a API expressar anatomia, conteúdo, variantes, tamanhos e estados sem exigir que a feature conheça a implementação interna.

## Processo

### 1. Modele o contrato

Inspecione todas as composições e estados aplicáveis da referência: default, hover, focus, pressed, disabled, loading e erro. Inclua teclado, ponteiro, semântica, overlay e retorno de foco.

Prefira ampliar uma API existente quando o novo caso conserva o mesmo papel. Crie outro componente quando o papel, a semântica ou o efeito para a pessoa mudar.

Conclua quando cada estado e interação tiver representação explícita na API ou uma composição documentada do componente.

### 2. Implemente com tokens

Use somente papéis semânticos:

- `context.tokens.colors`, `typography`, `spacing`, `borders` e `shadows`;
- `context.tokens.layout` e `sizes` para dimensões;
- `context.tokens.opacity` e `motion` para transparência e movimento;
- `AppIcons` para glifos Lucide;
- `context.motionDuration` para respeitar redução de movimento.

Um token novo descreve intenção, participa de `lerp`, aparece no catálogo e recebe teste quando cria contrato visual. Valores locais continuam aceitáveis somente quando pertencem ao dado ou à geometria interna sem significado compartilhado.

Todo texto usa a tipografia Geist por meio de estilo semântico ou herança deliberada. Componentes públicos definem sua aparência com tokens, mantendo `Theme.of(context)` apenas para estado de plataforma que o contrato de tema já controla.

Conclua quando temas claro e escuro usam os mesmos papéis, mudanças de estado preservam dimensões e nenhum literal substitui um token existente.

### 3. Publique o componente

Para um `App*` público:

1. exporte no barrel do nível;
2. exporte em `app_ui.dart` pelo barrel público;
3. registre em `AppComponentRegistry`;
4. demonstre variantes, tamanhos e estados no catálogo administrativo;
5. adicione teste da API pública e das interações relevantes.

Conclua quando uma feature conseguir importar apenas `app_ui.dart` e o catálogo permitir exercitar o contrato completo.

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
| Sombra | Apenas overlays e popovers usam `tokens.shadows.overlay`. |
| Ícone | Somente `AppIcons`; ícone decorativo fica fora da árvore semântica. |
| Movimento | Duração semântica; redução de movimento produz duração zero. |
| Densidade | Controles compactos preservam alvo interativo mínimo de 24×24 px. |

## Padrões de interação

| Padrão | Composição | Aceite observável |
| --- | --- | --- |
| Formulário | `AppForm` organiza os campos dentro de `AppDrawer`; ação primária envia e secundária cancela. | Clique no fundo não descarta dados; Cancelar ou Esc fecha quando ocioso; primeiro erro recebe foco; loading bloqueia repetição e fechamento. |
| Destrutiva | `AppAlertDialog` nomeia ação, objeto e impacto. | Esc cancela; fechar devolve foco; confirmação é inequívoca. |
| Estado remoto | `AppSkeleton`, `AppStateView` e conteúdo preservado durante refresh. | Retry mantém contexto; loading inicial conserva a estrutura. |
| Feedback | Inline corrige campo; toast informa resultado transitório; estado persistente permanece na página. | Mudança dinâmica é anunciada uma vez. |
| Overlay | Drawer para tarefa; dialog para conteúdo; alert dialog para decisão. | Scrim, foco, teclado e gesto de saída seguem o mesmo contrato. |

## Responsividade

Meça a janela com `MediaQuery.sizeOf` e o espaço local com `LayoutBuilder`. Use `context.windowClass`, `ResponsiveBuilder`, `ResponsiveValue<T>` e os breakpoints de `AppLayoutTokens`.

| Classe | Largura |
| --- | ---: |
| compact | `< 600` |
| medium | `600–839` |
| expanded | `840–1199` |
| large | `≥ 1200` |

Reorganize antes de ocultar. Quebre texto antes de truncar. Formulários usam uma coluna no compacto e agrupamentos relacionados nas demais larguras. Safe area e `viewInsets` protegem recorte e teclado. Redimensionar preserva foco, estado e rolagem.

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

Use pt-BR, voz ativa, ação concreta e explicação curta. Botões usam verbo + objeto; títulos ocupam uma linha; descrições usam até duas frases. Placeholder mostra formato e label permanece visível. Texto funcional compartilhado vive em `AppMessages`; conteúdo demonstrativo permanece no catálogo.

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

Conclua quando o catálogo, os testes, a comparação visual e os quatro comandos confirmarem o mesmo contrato.
