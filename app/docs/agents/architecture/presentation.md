# Camada presentation

Use este guia ao criar ou alterar páginas, fluxos, rotas, Bloc, estado de interface, ações ou texto visível. A implementação de referência é [`features/disciplinas/presentation`](../../../lib/src/features/disciplinas/presentation): replique suas fronteiras e seu fluxo de dados, não as regras específicas de Disciplinas.

Para componentes `App*`, tokens, tema, responsividade visual ou acessibilidade, siga [design-system.md](design-system.md).

## Fronteira

```text
widget → evento → Bloc → use case → Resultado
   ↑                 │
   └──── estado ─────┘
```

- `presentation` depende de Flutter, Bloc, navegação, `core` e `domain` da própria feature.
- Bloc recebe use cases pelo construtor e converte `Resultado` em estado de interface.
- JSON, HTTP, API models, repositories concretos e cache permanecem em `data`.
- `BuildContext`, overlays, foco, controllers e navegação permanecem nos widgets ou em classes `*Actions`.
- Tipos usados apenas para renderização são view data imutável em `presentation`; entidades e invariantes continuam em `domain`.

Conclua quando nenhum detalhe de infraestrutura atravessar a fronteira e nenhuma regra reutilizável de negócio estiver presa a um widget ou Bloc.

## Estrutura de referência

```text
presentation/
├── feature_page.dart
├── feature_view_data.dart       quando a tela precisar adaptar domínio
├── feature_formatters.dart      formatação pura para exibição
├── recurso_list/
│   ├── recurso_list_bloc.dart
│   ├── recurso_list_event.dart
│   ├── recurso_list_state.dart
│   ├── recurso_list_view.dart
│   ├── recurso_list_panel.dart
│   ├── recurso_list_item.dart
│   └── recurso_list_actions.dart
└── recurso_form/
    ├── recurso_form_bloc.dart
    ├── recurso_form_event.dart
    ├── recurso_form_state.dart
    └── recurso_form_view.dart
```

Crie somente os papéis exigidos pelo fluxo. A separação existe para manter estado, efeitos e renderização independentes; arquivos sem responsabilidade própria são ruído.

## Processo

### 1. Trace o fluxo

Leia a página, os use cases consumidos, os contratos do produto, a rota e os testes da feature. Liste:

- entradas da rota e do shell;
- intenções da pessoa usuária;
- estados inicial, loading, vazio, sucesso e falha;
- mutações concorrentes e indisponibilidades;
- feedback, navegação e sincronizações entre recursos.

Use [`disciplinas_page.dart`](../../../lib/src/features/disciplinas/presentation/disciplinas_page.dart) como traçador para fluxos com seleção mestre-detalhe, múltiplos Blocs, busca no shell e estado refletido na URL.

Conclua quando cada intenção e cada resposta de use case tiverem um destino observável na interface.

### 2. Modele eventos e estado

- Um evento representa uma intenção: carregar, atualizar, buscar, selecionar, enviar ou excluir.
- Um estado representa o snapshot renderizável completo.
- Use enum de status para o ciclo principal e flags separadas para operações ortogonais, como `isRefreshing` e `isDeleting`.
- Exponha disponibilidade derivada, como `canMutate`, no estado.
- Copie coleções para estruturas não modificáveis e preserve identidade de grupos não alterados quando isso limitar rebuilds.
- Use um enum `*Feedback` para resultados transitórios. Limpe o feedback ao iniciar nova operação para que o listener anuncie cada resultado uma vez.
- Modele seleção, expansão, busca e ordem no estado quando afetam o que a pessoa vê.

Use [`disciplinas_list_state.dart`](../../../lib/src/features/disciplinas/presentation/disciplinas_list/disciplinas_list_state.dart) para o contrato de lista e [`subtopicos_list_state.dart`](../../../lib/src/features/disciplinas/presentation/subtopicos_list/subtopicos_list_state.dart) para estado particionado por item pai.

Conclua quando toda transição puder ser descrita como `estado atual + evento → novo estado`, incluindo repetição de envio e operações simultâneas.

### 3. Implemente o Bloc

- Injete funções de use case, nunca repositories concretos.
- Proteja submissões e mutações repetidas antes da primeira emissão assíncrona.
- Faça pattern matching exaustivo de `Sucesso`, `ViolacaoRegra` e `FalhaTecnica`.
- Preserve dados úteis durante refresh ou mutação; loading estrutural pertence somente à carga inicial.
- Traduza códigos de resultado em estados sem comparar mensagens de erro.
- Mantenha busca, ordenação e adaptação para view data determinísticas e testáveis.

Use [`disciplinas_list_bloc.dart`](../../../lib/src/features/disciplinas/presentation/disciplinas_list/disciplinas_list_bloc.dart) para listas e [`disciplinas_form_bloc.dart`](../../../lib/src/features/disciplinas/presentation/disciplinas_form/disciplinas_form_bloc.dart) para submissão de formulário.

Conclua quando o Bloc não usar `BuildContext`, não construir widgets e cobrir todos os resultados declarados pelo use case.

### 4. Componha a página

- A `*Page` obtém use cases do contexto, cria os Blocs e dispara a carga inicial.
- A página coordena Blocs irmãos com `BlocListener`; cada Bloc continua dono apenas do próprio estado.
- A `*View` escolhe loading, erro, vazio ou conteúdo e converte feedback em efeito visível.
- `*Panel`, `*Header` e `*Item` recebem dados e callbacks; preferencialmente são widgets puros.
- `*Actions` abre drawer ou diálogo, aguarda o resultado e então despacha o evento correspondente.
- Formulários possuem Bloc próprio. O widget mantém `FormState`, controllers e foco; sucesso fecha a superfície retornando um valor explícito.

Use `BlocSelector`, `buildWhen`, `listenWhen` e `RepaintBoundary` onde a feature de Disciplinas demonstra uma fronteira real de rebuild ou efeito. Cada filtro deve nomear exatamente os campos que o consumidor observa.

Conclua quando renderização, estado e efeitos tiverem um único dono e uma alteração localizada não reconstruir o workspace inteiro sem necessidade.

### 5. Preserve rota e shell

- Cada área principal ocupa uma branch e possui URL representativa.
- Inicialize o Bloc com parâmetros da rota; reflita busca, filtro e ordem na query string.
- Use `replace` para estado navegacional transitório e debounce apenas para entradas contínuas.
- Registre busca e ações contextuais com `AppShellController`; remova o registro no `dispose`.
- Preserve seleção, foco e rolagem ao atualizar URL ou alternar largura.

Conclua quando um deep link reproduzir o mesmo estado visível e voltar/avançar não criar estados impossíveis.

### 6. Renderize com o design system

Features importam `core/ui/app_ui.dart` e compõem `App*`. Escolha feedback, superfícies temporárias, estados e texto conforme [design-system.md](design-system.md).

Conclua quando a feature não reconstruir localmente um componente público nem introduzir valores visuais com papel já coberto por token.

### 7. Teste o contrato

Teste Blocs com fakes de repository por meio dos use cases, seguindo [`disciplinas_list_bloc_test.dart`](../../../test/features/disciplinas/presentation/disciplinas_list/disciplinas_list_bloc_test.dart).

Cubra, conforme o fluxo:

- estado inicial derivado da rota;
- carga, retry, vazio e falha;
- sucesso, violação de regra e falha técnica de cada mutação;
- bloqueio de operação repetida;
- busca, ordem, seleção e expansão;
- sincronização entre recursos e feedback transitório;
- widgets para semântica, foco, navegação e responsividade afetados.

Conclua quando remover uma transição, um efeito ou um parâmetro de rota relevante fizer pelo menos um teste falhar.

### 8. Verifique

Em `app/`, execute:

```bash
dart format lib test
flutter analyze
flutter test
flutter build web
```

Conclua quando os comandos passarem e o fluxo funcionar por teclado e ponteiro nas larguras afetadas.
