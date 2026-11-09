# Identidade do Prumo.app

## Decisões aprovadas

| Tema | Decisão |
| --- | --- |
| Nome de destino | **Prumo.app** |
| Categoria | Planejamento de estudos para concursos |
| Metáfora central | Alinhamento, direção e construção de uma base firme |
| Personalidade | Sólida, serena, metódica, adulta e humana |
| Princípio verbal | Clareza antes de metáfora; ação concreta antes de motivação |
| Promessa | Organizar prioridades, Revisões e tempo real sem transformar constância em cobrança |

O risco nominal de Prumo.app foi aceito para esta implementação. Repositório e package identifiers permanecem inalterados até uma decisão operacional posterior.

## Nome e assinatura

Use **Prumo.app** como identificador do produto no trabalho de reposicionamento. O uso de **Prumo** como nome verbal sem o sufixo depende da decisão sobre canais e proteção do nome.

**Assinatura:** Estudo no rumo certo.

**Promessa secundária:** Prioridade, constância e domínio.

Mensagens públicas descrevem preparação e organização; não apresentam o método como garantia de aprovação.

## Voz

A voz é direta, brasileira, adulta, serena e orientadora.

- Comece pela ação ou decisão concreta.
- Use a metáfora de alinhamento para explicar a marca, não para renomear cada controle.
- Explique limites e cortes sem culpa.
- Celebre o suficiente e encerre; não convide a produzir mais depois da conclusão.
- Prefira processo observável a motivação abstrata.

## Direção visual: mineral editorial

O sistema aprovado usa continuidade editorial na tipografia e o eixo vertical com três marcas como símbolo das Revisões de 1, 7 e 30 dias.

A identidade combina a precisão de uma ferramenta de produtividade com a calma de um ambiente de leitura. Deve parecer firme sem rigidez e sofisticada sem elitismo.

### Cor

| Papel | Claro | Escuro |
| --- | --- | --- |
| Base | `#F3F1EA` | `#0E2424` |
| Superfície | `#FCFBF7` | `#153131` |
| Texto principal | `#172B2B` | `#F3F1EA` |
| Texto secundário | `#4F6262` | `#C3CCC7` |
| Cobre principal | `#9F4D32` | `#E69A78` |
| Verde de sucesso | `#356B57` | `#A9D2BE` |

Os demais valores vivem em `AppColorPrimitives` e são consumidos somente por papéis semânticos. Texto, foco e estados interativos atendem aos contrastes AA verificados em `design_tokens_test.dart`.

### Forma e movimento

- Use eixos, alinhamentos, módulos apoiados e linhas de aferição.
- Use textura apenas como nuance, sem simular papel literalmente.
- Movimento comunica encaixe, alinhamento e consolidação.
- Preserve foco visível e respeite redução de movimento.

### Símbolo

O símbolo é um eixo vertical com três marcas, peso e base comum. As três marcas representam as Revisões de 1, 7 e 30 dias. Use as versões oficiais em 16, 24, 32 e 128 px, monocromático, favicon e fundos claro/escuro.

### Tipografia

Fraunces permanece em marca e títulos, Newsreader sustenta leitura e Inter atende controles, rótulos e numerais. A escala definida no tema é a fonte de verdade para tamanhos, pesos e alturas.

### Iconografia

Phosphor permanece como família. Pesos, tamanhos e estados seguem o Design System e `AppIcons`; widgets não acessam glifos diretamente.

## Guardrails

Prefira abstração de alinhamento e base. Não use ícone literal de construção civil, nível de bolha, seta de crescimento ou alvo genérico. A experiência também exclui confete, pulso de urgência e recompensa infinita.

## Assets e aplicação

O pacote final deve conter lockups horizontal e vertical, símbolo, versões monocromáticas, ícone e favicon, com área de respiro, tamanhos mínimos e usos incorretos documentados.

- Área de respiro: pelo menos metade da largura do símbolo em todos os lados.
- Mínimo horizontal: 160 px sem assinatura e 240 px com assinatura.
- Mínimo do símbolo: 16 px digital; prefira 24 px ou mais em controles e navegação.
- Use `prumo-monochrome-mineral.svg` sobre fundos escuros e `prumo-monochrome-ink.svg` sobre fundos claros.
- Preserve proporção, cores e alinhamento; não incline, comprima ou aplique gradiente.

Valide o sistema em todos os pontos de contato e estados da interface. Cubra desktop, tablet e celular, temas claro/escuro, teclado, foco e texto ampliado.

Os assets oficiais ficam em `app/assets/brand/` com o prefixo `prumo-`. O histórico da identidade anterior permanece no Git.
