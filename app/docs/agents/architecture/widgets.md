# Widgets Flutter

Este é o guia autoritativo para criar, alterar ou revisar widgets Flutter do projeto. A referência visual é a implementação atual do shadcn/ui Base UI; o código do repositório é a fonte de verdade para APIs, tokens e componentes já disponíveis.

## Processo

### 1. Inventarie

Antes de editar, inspecione o widget afetado, seus testes, `lib/src/core/ui/app_ui.dart`, `AppComponentRegistry` e os tokens acessíveis por `context.tokens`.

Quando houver componente equivalente no [shadcn/ui Base UI](https://ui.shadcn.com/docs/components/base), examine a página oficial atual e todas as composições, variantes e estados aplicáveis. Considere parte da referência a anatomia, tipografia, espaçamento, dimensões, ícones, bordas, raios, overlays e comportamento — não apenas a captura do estado inicial.

Conclua quando cada requisito estiver associado a uma destas decisões: reutilizar um `App*`, estender sua API ou criar um novo `App*`; e quando nenhuma composição ou estado relevante da referência estiver sem destino.

### 2. Modele

Componentes reutilizáveis expõem uma API `App*` baseada no papel que exercem no produto. Use parâmetros nomeados, construtor `const` quando possível, variantes e tamanhos tipados, estados explícitos e callback nulo para representar indisponibilidade.

Mantenha conceitos diferentes em APIs diferentes mesmo quando compartilham infraestrutura. Por exemplo, `AppAlertDialog` representa uma decisão que exige confirmação; `AppDialog` representa conteúdo ou tarefa modal.

Átomos não dependem de composições superiores; moléculas combinam átomos; organismos combinam os níveis anteriores; templates organizam a página. Exporte o componente no barrel do nível e no barrel público.

Conclua quando a API pública expressar toda a anatomia, variantes, tamanhos, estados, conteúdo e ações exigidos sem obrigar a feature a reconstruir internamente o componente.

### 3. Implemente

Features importam `core/ui/app_ui.dart` e consomem `App*`. A implementação usa Flutter e a infraestrutura do projeto, sem pacote externo de componentes. Controles Material podem permanecer como detalhe interno de plataforma ou acessibilidade, encapsulados por `App*` e visualmente definidos pelos tokens.

Use `context.tokens.colors`, `context.tokens.typography`, `context.tokens.spacing`, `context.tokens.borders`, `context.tokens.layout`, `context.tokens.sizes`, `context.tokens.opacity`, `context.tokens.motion` e `AppIcons`. Um token novo descreve intenção, participa de `copyWith` e `lerp`, aparece integralmente no catálogo de tokens e recebe teste quando introduz um contrato visual.

Todo texto visível recebe um estilo tipográfico semântico ou herda deliberadamente um estilo de um ancestral. Use Geist, inclusive em títulos, controles, rótulos e numerais. Ícones usam `AppIcons`/Phosphor Light e tamanhos semânticos.

Construa profundidade com superfícies semânticas, bordas e raios. A interface é plana; sombra pertence somente a overlays e popovers. Use borda semântica de 1 px como separação, raio discreto e foco por ring, preservando as dimensões entre estados.

Conclua quando o widget não contiver valor visual literal que já tenha papel semântico, não acessar `Theme.of(context).colorScheme` ou `Theme.of(context).textTheme`, e não duplicar um componente público existente.

### 4. Componha o comportamento

Implemente os estados `default`, `hover`, `focus`, `pressed` e `disabled` em todo controle interativo. Formulários também cobrem erro; ações assíncronas cobrem loading sem alterar o tamanho ou permitir submissão repetida.

Use os padrões de interação, responsividade, acessibilidade e texto deste documento. Preserve estado, foco e rolagem quando a largura, a rota ou o carregamento mudar.

Conclua quando cada transição pode ser acionada por teclado e ponteiro, produz o feedback correspondente e retorna o foco ao ponto correto ao fechar uma superfície temporária.

### 5. Demonstre e teste

Componente público novo entra em `AppComponentRegistry` e na aba correspondente do catálogo administrativo. A demonstração apresenta todas as variantes, tamanhos, composições e estados relevantes; interações como abrir, selecionar, ordenar, filtrar, carregar, falhar e tentar novamente devem ser exercitáveis.

Adicione testes da API pública e de pelo menos um estado relevante. Cubra semântica, foco, teclado, contraste, texto a 200%, largura e preservação de estado quando esses comportamentos fizerem parte da mudança.

Conclua quando o catálogo permite comparar a implementação com a referência e os testes falham caso o contrato introduzido seja removido ou regredido.

### 6. Verifique

Compare visualmente a implementação com a referência oficial nos temas claro e escuro e nas larguras afetadas. Corrija diferenças de tipografia, cor, espaçamento, dimensão, alinhamento, ícone, borda, raio, overlay e estado interativo.

Em `app/`, execute:

```bash
dart format lib test
flutter analyze
flutter test
flutter build web
```

Conclua quando a comparação não apresentar divergência não intencional, os comandos passarem e todos os critérios aplicáveis deste documento estiverem atendidos.

## Gramática visual

| Aspecto | Regra |
| --- | --- |
| Referência | Preserve a aparência e o comportamento reconhecíveis do shadcn/ui Base UI atual. |
| Cor | Use os papéis semânticos de `AppTokens`; a base neutra é zinc nos temas claro e escuro. |
| Tipografia | Geist em toda a interface; hierarquia por tamanho, peso e espaçamento. |
| Superfície | Separe `canvas`, `surface`, `card`, `popover` e contêineres de estado pelo papel, não por elevação. |
| Borda | 1 px semântico é o separador padrão; foco usa ring perceptível. |
| Raio | Controles usam raio discreto; cards e modais podem usar o próximo nível; cápsula exige significado circular. |
| Sombra | Use somente `context.tokens.shadows.overlay` em overlay ou popover. |
| Densidade | Controles comuns seguem a base compacta atual; o alvo interativo atende ao mínimo de 24×24 px. |
| Ícone | Use `AppIcons`; ícone decorativo fica fora da árvore semântica. |
| Movimento | Use `context.motionDuration`; redução de movimento resulta em duração zero. |
| Modal | Use o scrim e o desfoque semânticos do projeto, preservando a superfície clara e a borda. |

## Padrões de interação

| Padrão | Comportamento exigido | Aceite observável |
| --- | --- | --- |
| Formulário | Formate durante a escrita, valide conteúdo ao sair e valide tudo no envio. Preserve dados e anuncie o primeiro erro. Edição oferece salvar/cancelar e protege abandono. | Tab segue a ordem visual; Enter não duplica envio; falha mantém os valores. |
| Lista remota | Mostre skeleton inicial; mantenha busca, filtro, ordem e consulta na URL; carregue páginas sem apagar itens. | Filtro reinicia cursor; retry continua a página atual; novo lote preserva foco. |
| Destrutiva | Ação reversível executa e oferece “Desfazer”. Ação irreversível ou em cascata abre `AppAlertDialog` e nomeia ação, objeto e impacto. | Esc cancela; foco retorna ao acionador; undo restaura item e posição. |
| Feedback | Use inline para correção local, snackbar para resultado transitório, banner para condição persistente e dialog para decisão. | Mudança dinâmica é anunciada uma vez; loading mantém conteúdo útil. |
| Navegação | Use uma branch por área e mantenha a URL representativa. “Navegável pelo menu” significa entrada no menu lateral, não no cabeçalho. | Deep link abre a área correta; branch preserva scroll, filtros, formulário e histórico. |

Skeleton mantém a estrutura. Spinner representa operação curta. Estado vazio explica o motivo e oferece uma ação. Erro oferece recuperação. Offline preserva dados já disponíveis.

## Responsividade

Meça a janela com `MediaQuery.sizeOf` e o espaço local com `LayoutBuilder`. Use `context.windowClass`, `ResponsiveBuilder`, `ResponsiveValue<T>` e breakpoints de `AppLayoutTokens`.

| Classe | Largura | Navegação |
| --- | ---: | --- |
| compact | `< 600` | barra inferior |
| medium | `600–839` | menu lateral de ícones e barra de comando |
| expanded | `840–1199` | menu lateral de ícones e barra de comando |
| large | `≥ 1200` | menu lateral de ícones e barra de comando |

Reorganize antes de esconder e quebre texto antes de truncar. Formulários usam uma coluna no compacto e até duas colunas relacionadas nas demais larguras. Dialog ocupa a tela no compacto e usa largura máxima nas demais. Dados viram cards apenas quando a comparação tabular continuar compreensível. Safe area e `viewInsets` protegem recorte e teclado.

Aceite responsivo: 390, 720, 1024 e 1440 px; orientação livre; texto a 200%; redimensionamento preserva foco, estado e rolagem; ações essenciais permanecem visíveis; nenhum widget declara breakpoint literal.

## Acessibilidade

WCAG 2.2 AA bloqueia a entrega.

- Texto comum atende 4,5:1; texto grande, foco e componente atendem 3:1 nos temas claro e escuro.
- Tab segue a ordem visual; setas percorrem grupos de rádio; Esc fecha modal; fechar restaura foco.
- Todo ícone acionável tem nome; ícone decorativo é excluído; label e controle formam uma unidade semântica.
- Erro, loading, snackbar, resultado e novo lote são anunciados uma vez.
- Foco usa `focusRing` visível e não depende somente de cor.
- O alvo de ponteiro atende a 24×24 px; texto a 200% reorganiza sem overflow.
- Status combina texto ou ícone com cor.

Conclua quando testes de Semantics encontram nome, papel, estado e ação; `meetsGuideline` cobre rótulo e contraste; e o widget continua operável somente por teclado.

## Texto visível

Use pt-BR, voz ativa, ação concreta e explicação curta. A mensagem informa o ocorrido e o próximo passo.

| Tipo | Estrutura | Exemplo |
| --- | --- | --- |
| Erro | ocorrido + resolução | “Não foi possível salvar. Tente novamente; seus dados foram preservados.” |
| Sucesso | resultado concluído | “Registro criado.” |
| Aviso | condição + consequência | “Há alterações não salvas. Se sair, elas serão perdidas.” |
| Confirmação | ação + objeto + impacto | “Excluir registro? Os dados associados também serão removidos.” |
| Vazio | motivo + ação | “Nenhum registro disponível. Crie o primeiro.” |
| Loading | ação em andamento | “Salvando alterações…” |

Botão usa verbo + objeto. Título ocupa uma linha; descrição usa até duas frases; snackbar usa uma frase e uma ação. Placeholder mostra formato e label permanece visível. Use capitalização de frase. Texto funcional compartilhado vive em `AppMessages`; conteúdo demonstrativo permanece no modelo da feature.
