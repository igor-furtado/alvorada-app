# Plano de reposicionamento — Prumo.app

**Status:** implementação concluída; lançamento e validações externas pendentes

**Atualizado em:** 9 nov. 2026

**Escopo:** marca, linguagem de produto, identidade visual e aplicação Flutter Web

## Objetivo

Reposicionar o produto como **Prumo.app**, uma ferramenta de planejamento de estudos para concursos que transforma Edital, tempo disponível e Revisões em uma preparação realista, priorizada e sustentável.

O produto preserva seus princípios: recuperação ativa, Revisões programadas, descanso protegido, ausência de gamificação punitiva e nenhuma promessa de aprovação.

## Decisões consolidadas

| Tema | Decisão |
| --- | --- |
| Nome | **Prumo.app**; **Prumo** no uso verbal |
| Categoria | Planejamento de estudos para concursos |
| Assinatura | **Estudo no rumo certo.** |
| Promessa | Prioridade, constância e domínio em uma rotina real |
| Personalidade | Sólida, serena, metódica, adulta e humana |
| Direção visual | Mineral editorial, com azul-petróleo, superfícies minerais e cobre como acento |
| Princípio verbal | Clareza antes de metáfora; ação concreta antes de motivação |
| Conceito-alvo | **Concurso**, com **Concurso prioritário** quando houver mais de um |
| Rotas públicas | `/concursos`, mantendo redirecionamentos temporários de `/horizontes` |

As regras permanentes de marca estão em `app/docs/agents/brand/`. As regras de comportamento, método e vocabulário do produto estão em `app/docs/agents/product/` e `CONTEXT.md`. O Design System contém somente regras de interface.

## Situação dos blocos

| Bloco | Estado | Resultado |
| --- | --- | --- |
| 1. Documentação | Concluído | Marca, produto e Design System separados; journeys removidas |
| 2. Vocabulário | Concluído | Alvorada e Horizonte migrados para Prumo e Concurso |
| 3. Identidade | Concluído | Assets, paleta, assinatura e registro de ícones atualizados |
| 4. Flutter | Concluído | Shell, páginas, rotas, conteúdo e responsividade migrados |
| 5. Web/PWA | Concluído | Título, manifesto, favicon e ícones de instalação atualizados |
| 6. Qualidade | Concluído | Formatação, análise, testes, build web e inspeção visual aprovados |
| 7. Lançamento | Pendente | Disponibilidade nominal, canais, publicação e comunicação externa |

## Alterações implementadas

- `AppBrand`, mensagens canônicas, navegação e metadados usam Prumo.app.
- A feature `horizons` passou a `contests`, incluindo tipos, arquivos e testes.
- A navegação usa Concurso/Concursos; URLs legadas redirecionam para as novas rotas.
- A paleta passou a azul-petróleo, mineral e cobre, com temas claro e escuro.
- Os assets antigos foram substituídos por lockups, símbolo, ícone e versões monocromáticas do Prumo.
- O manifesto e os ícones PWA foram regenerados para a nova identidade.
- README, documentação da API, glossário e ADR foram alinhados ao novo vocabulário.
- O guia misto da marca anterior foi removido após a preservação das decisões relevantes nas documentações canônicas.

## Validação concluída

- `dart format lib test`
- `flutter analyze`
- `flutter test` — 27 testes aprovados
- `flutter build web`
- validação do manifesto e dos SVGs
- verificação de links locais da documentação
- revisão manual em claro e escuro, larguras compactas e texto ampliado
- busca por referências antigas; restam apenas redirecionamentos e testes de compatibilidade, além do nome técnico do repositório ainda existente

## Pendências de lançamento

Estas pendências não bloqueiam o código atual, mas precisam ser resolvidas antes de uma divulgação pública coordenada:

1. Validar disponibilidade e risco do nome Prumo nas classes aplicáveis.
2. Definir domínio principal, identificadores de loja e canais sociais.
3. Decidir se o nome técnico do repositório e outros identificadores operacionais serão migrados.
4. Atualizar páginas públicas, screenshots e materiais de loja quando existirem.
5. Preparar a comunicação curta: **“Alvorada agora é Prumo.”**
6. Publicar e monitorar erros, abandono dos fluxos e dúvidas terminológicas.

## Critérios para encerrar o reposicionamento

- nome e canais prioritários validados;
- aplicação publicada com os novos metadados e assets;
- nenhum asset antigo carregado em produção;
- rotas legadas verificadas após a publicação;
- comunicação de lançamento publicada sem sugerir mudança de método ou perda de dados;
- monitoramento inicial concluído sem regressões críticas.
