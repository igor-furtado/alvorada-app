# Prumo

O Prumo organiza Concursos e Disciplinas em um catálogo compartilhado. Seu vocabulário mantém Editais e Tópicos consistentes em toda a interface, API e persistência.

## Concursos

**Concurso**:
O concurso-alvo que reúne órgão, cargo ou especialidade, condições de ingresso, vagas, remuneração, jornada, prova, critérios de pontuação, dados de inscrição e um Edital. Uma pessoa pode manter mais de um Concurso.
_Evitar_: Concurso cadastrado, projeto, meta

**Regime de contratação**:
O vínculo jurídico previsto para o cargo de um Concurso, classificado como Estatutário ou Celetista.
_Evitar_: Tipo de contrato, vínculo empregatício

**Concurso prioritário**:
O Concurso escolhido como principal. A proximidade da prova desempata Concursos com a mesma prioridade.
_Evitar_: Concurso favorito, concurso mais importante

**Edital**:
O recorte estudável vigente do edital de abertura de um Concurso, organizado em Disciplinas e Tópicos e atualizado quando uma retificação altera o conteúdo cobrado. Cada Concurso possui um único Edital; datas e dados de inscrição pertencem ao Concurso.
_Evitar_: Pauta, mapa, grade, lista de matérias

**Conteúdo Programático do Edital**:
O título da tela usada para selecionar, no catálogo compartilhado, os Tópicos cobrados no Edital de um Concurso.
Sua lista separa as Disciplinas que já possuem Tópicos selecionados no conteúdo programático das demais Disciplinas. A busca percorre os Tópicos de todas as Disciplinas e, enquanto houver uma consulta, exibe somente as Disciplinas que possuam Tópicos correspondentes, preservando essa separação.
No drawer de edição, o eyebrow mostra o órgão ou instituição do Concurso de origem e a descrição sob o título mostra o cargo; nos drawers de criação e edição de Tópico, o eyebrow identifica a Disciplina de origem.

**Vínculo do Edital**:
A associação entre um Edital e um Tópico do catálogo. A presença da Disciplina é derivada dos Tópicos vinculados.
No editor do Edital, a pessoa percorre as Disciplinas, prepara uma seleção de Tópicos e salva o conjunto de alterações de uma vez.
_Evitar_: Vínculo de Disciplina

## Disciplinas

**Catálogo de Disciplinas**:
A tela compartilhada em que a pessoa organiza Disciplinas e seus Tópicos para reutilizá-los nos Editais e planos de estudo.
A ordem das Disciplinas pode ser reorganizada no catálogo por arrastar e soltar e é reutilizada nas demais telas.

**Disciplina**:
Uma área de conhecimento presente em um ou mais Editais e que contém, obrigatoriamente, o Tópico Revisão de Véspera.
_Evitar_: Matéria, curso, módulo

**Tópico**:
A unidade de conteúdo compartilhável entre Editais. Um Tópico é mantido uma única vez no catálogo. Excluí-lo do catálogo também remove seus vínculos de todos os Editais quando ainda não houver progresso de estudo; depois que algum progresso for registrado, o Tópico deve ser preservado.
Ao editar os Tópicos de uma Disciplina, a pessoa trabalha em um único formulário com toda a lista: pode alterar nomes diretamente, remover itens e digitar ou colar um ou vários Tópicos novos, um por linha. As mudanças permanecem como rascunho até serem salvas juntas em uma única operação.
A ordem dos Tópicos editáveis pode ser reorganizada no catálogo por arrastar e soltar; Revisão de Véspera permanece sempre na última posição.
_Evitar_: Capítulo, assunto duplicado, unidade por edital

**Revisão de Véspera**:
O Tópico estrutural, obrigatório e sempre último de cada Disciplina. Ele participa automaticamente de todo Edital que contenha a Disciplina e não pode ser renomeado nem excluído.
_Evitar_: Menu Véspera, lista de gatilhos no app, conteúdo de revisão no app

**Peso combinado**:
A prioridade de uma Disciplina ou Tópico calculada pela relevância em cada Edital e pela proximidade de seus Concursos.
_Evitar_: Dificuldade, importância absoluta

**Peso no Edital**:
O valor decimal positivo atribuído a uma Disciplina dentro de um Edital. Ele expressa a relevância relativa informada para aquele Concurso e pode variar entre Editais.
_Evitar_: Peso global da Disciplina, dificuldade

## Metodologia de estudo

**Semana de estudos**:
A visão semanal em que a pessoa distribui estudos iniciais e Revisões programadas por dia, podendo filtrar os cartões por Concurso e reorganizá-los. Ela é um destino próprio da navegação principal.
Ao adicionar um estudo pela Semana, a pessoa escolhe um Tópico ainda não planejado; o sistema o inclui no dia atual (ou no primeiro dia da semana exibida) e abre imediatamente o modo foco.
_Evitar_: Calendário de horas, grade de produtividade

**Estudo planejado**:
O vínculo Concurso–Tópico que recebeu uma data na Semana de estudos. Ao iniciar, abre o modo foco; a data organiza o cronograma, mas não mede o tempo estudado.
_Evitar_: Sessão cronometrada, evento de calendário

**Ciclo de estudo do Tópico**:
O método de referência de 100 minutos usado para o primeiro estudo de um Tópico. Ele apresenta Estudo da teoria, escrita de memória, conferência e consolidação e um bloco integrado de Questões e Caderno de Erros. A pessoa pode navegar livremente entre as atividades. Teoria, memória e conferência determinam a conclusão do Tópico; as questões determinam seu desempenho. Ao final, a pessoa pode escolher agendar revisões para D+1, D+7 e D+30, em qualquer combinação ou nenhuma. A definição normativa está em `METODOLOGIA.md`.
_Evitar_: Sessão configurável, ordem bloqueada, tempo estudado como desempenho

**Estudo da teoria**:
O primeiro bloco do ciclo, com 40 minutos, destinado ao conteúdo teórico do Tópico independentemente do formato utilizado. Leitura e videoaula são exemplos de meios possíveis.
_Evitar_: Etapa de leitura, etapa de videoaula

**Escrita de memória**:
O registro, sem consultar o material, do que a pessoa aprendeu sobre o Tópico. Dura 5 minutos.
_Evitar_: Resumo inicial, consulta guiada

**Conferência e consolidação**:
O bloco de 15 minutos em que a pessoa volta ao material, compara com a escrita de memória, corrige distorções, faz anotações e destaca partes importantes. O resumo é uma consequência desse trabalho.
_Evitar_: Criação do resumo, etapa de resumo

**Bloco de questões**:
O bloco de referência de 40 minutos em que a pessoa resolve questões de bancas variadas, marca cada resposta como certa ou errada e alimenta simultaneamente o Caderno de Erros. Na primeira versão, são registrados apenas os contadores acumulados de acertos e erros, usados para calcular o desempenho do Tópico no Concurso. Questões não bloqueiam a conclusão do Tópico.
_Evitar_: Simulado, banco de questões

**Caderno de Erros**:
O registro dos erros cometidos nas questões. A metodologia prevê o motivo de cada erro, mas a primeira versão registra somente a quantidade de erros durante o bloco de questões.

**Revisão programada**:
A revisão opcional criada, por escolha da pessoa, para D+1, D+7 ou D+30, considerando D como o dia de conclusão do ciclo. O ciclo pode terminar sem Revisão programada.
_Evitar_: Revisão de Véspera, revisão obrigatória

**Tópico concluído no Edital**:
O estado da combinação Concurso–Tópico quando Estudo da teoria, escrita de memória e conferência e consolidação estiverem concluídos. A resolução de questões não é requisito de conclusão.
_Evitar_: Tópico com cronômetro encerrado, Tópico com questões obrigatórias

**Cronômetro de estudo**:
Recurso exclusivamente visual do modo foco para orientar a pessoa nas durações de referência. Seu tempo não é persistido nem usado como indicador de desempenho.
_Evitar_: Horas estudadas, tempo acumulado, produtividade por duração
