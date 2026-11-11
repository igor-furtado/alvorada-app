# Prumo

O Prumo organiza Concursos e Disciplinas em um catálogo compartilhado. Seu vocabulário mantém Editais, Tópicos e Subtópicos consistentes em toda a interface, API e persistência.

## Concursos

**Concurso**:
O concurso-alvo que reúne cargo, instituição organizadora, data de prova, dados de inscrição e um Edital. Uma pessoa pode manter mais de um Concurso.
_Evitar_: Concurso cadastrado, projeto, meta

**Concurso prioritário**:
O Concurso escolhido como principal. A proximidade da prova desempata Concursos com a mesma prioridade.
_Evitar_: Concurso favorito, concurso mais importante

**Edital**:
O recorte estudável do edital oficial de um Concurso, organizado em Disciplinas e Tópicos. Datas e dados de inscrição pertencem ao Concurso.
_Evitar_: Pauta, mapa, conteúdo programático, grade, lista de matérias

## Disciplinas

**Disciplina**:
Uma área de conhecimento presente em um ou mais Editais e que contém, obrigatoriamente, o Tópico Revisão de Véspera.
_Evitar_: Matéria, curso, módulo

**Tópico**:
A unidade de conteúdo compartilhável entre Editais. Um Tópico é mantido uma única vez no catálogo.
_Evitar_: Capítulo, assunto duplicado, unidade por edital

**Revisão de Véspera**:
O Tópico estrutural, obrigatório e sempre último de cada Disciplina. Ele não pode ser renomeado, excluído nem receber Subtópicos.
_Evitar_: Menu Véspera, lista de gatilhos no app, conteúdo de revisão no app

**Subtópico**:
Um detalhamento de um Tópico usado para organizar seu escopo.
_Evitar_: Subitem, subtarefa

**Peso combinado**:
A prioridade de uma Disciplina ou Tópico calculada pela relevância em cada Edital e pela proximidade de seus Concursos.
_Evitar_: Dificuldade, importância absoluta
