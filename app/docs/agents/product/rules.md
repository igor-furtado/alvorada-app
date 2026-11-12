# Regras do produto

## Definição

O produto organiza Concursos e Disciplinas. Ele mantém os dados dos Concursos e o catálogo compartilhado de Disciplinas e Tópicos; não substitui o Edital oficial nem o material de estudo.

## Áreas principais

- Concursos e Disciplinas são as duas áreas principais do produto.
- Concursos é a área inicial.
- Cada área usa uma branch própria e mantém a URL representativa.
- A administração do design system permanece como ferramenta interna, fora da navegação principal.

## Concursos

- Um Concurso reúne órgão e sigla opcional, cargo ou especialidade, banca, vagas, vencimento, carga horária semanal, local, data e horários da prova, requisitos, critérios de pontuação, prioridade, arquivamento e progresso do Edital.
- Os dados complementares são opcionais para permitir Concursos ainda sem edital publicado ou com informações pendentes.
- Instituição, cargo ou especialidade e prioridade podem ser editados sem alterar o progresso do Edital; os demais dados do Concurso podem ser preenchidos, alterados ou removidos.
- Quando houver horário de prova, início e término são informados juntos e o término deve ser posterior ao início.
- A pessoa pode manter mais de um Concurso e escolher um Concurso prioritário.
- Somente um Concurso ativo pode ser prioritário por vez.
- A prova mais próxima organiza a lista quando aplicável; Concursos sem data continuam acessíveis.
- Cada Concurso possui um único Edital, correspondente ao recorte estudável vigente do edital de abertura; uma retificação que altere o conteúdo cobrado atualiza esse mesmo Edital.
- O Edital é composto nos detalhes do Concurso por meio do vínculo com Tópicos existentes no catálogo; a criação e a alteração de Disciplinas e Tópicos permanecem na área Disciplinas.
- A presença de uma Disciplina no Edital é derivada de seus Tópicos vinculados.
- Adicionar uma Disciplina ao Edital é uma operação em lote que vincula todos os seus Tópicos comuns atuais; essa operação não cria um vínculo próprio com a Disciplina.
- Adicionar uma Disciplina parcialmente vinculada cria somente os vínculos ausentes; repetir a operação não duplica vínculos.
- Tópicos criados no catálogo depois dessa operação não entram automaticamente no Edital.
- Um Tópico também pode ser vinculado individualmente a uma Disciplina já presente no Edital.
- O mesmo editor permite remover um Tópico do Edital sem excluí-lo do catálogo.
- Remover o último Tópico comum de uma Disciplina também retira do Edital a Disciplina derivada e sua Revisão de Véspera.
- O Edital não mantém ordem própria para Disciplinas ou Tópicos.
- Abrir uma Disciplina pelos detalhes do Concurso apresenta o recorte dessa Disciplina naquele Edital; a área Disciplinas apresenta o catálogo compartilhado.
- Arquivar preserva o Concurso. Excluir remove o Concurso e seu Edital de forma irreversível.

## Disciplinas

- A área Disciplinas preserva a ordem do catálogo por padrão e oferece ordenação alfabética sem alterar a ordem persistida.
- Uma Disciplina contém Tópicos.
- Cada Tópico compartilhado entre Editais existe uma única vez no catálogo.
- Não é permitido excluir uma Disciplina ou um Tópico usado por algum Edital.
- Quando não houver uso em Editais, excluir uma Disciplina remove seus Tópicos.

## Revisão de Véspera

- Toda Disciplina recebe automaticamente o Tópico Revisão de Véspera.
- Ele permanece na última posição e não pode ser renomeado nem excluído.
- Ele aparece automaticamente em todo Edital que contenha a Disciplina, sem vínculo próprio.
- Seu conteúdo permanece no material de estudo; o Prumo mantém apenas o tópico estrutural no catálogo.

## Critério de aceite

Uma mudança preserva as regras do produto quando mantém Concursos e Disciplinas como únicas áreas principais, usa o vocabulário canônico e protege a Revisão de Véspera como tópico fixo de cada Disciplina.
