# Contexto do domínio

## Propósito

O Foco ajuda uma pessoa a organizar o conteúdo que precisa estudar. A aplicação deve reduzir a burocracia de cadastro e permitir que a estrutura dos estudos seja compreendida rapidamente.

O produto começa como um catálogo hierárquico, mas deve poder crescer para planejamento, sessões de estudo, revisões, questões e acompanhamento de progresso.

## Modelo atual

```text
Disciplina
└── Tópico
    └── Subtópico
```

- Uma **Disciplina** representa uma área de conhecimento estudada.
- Um **Tópico** representa uma divisão de conteúdo dentro de uma disciplina.
- Um **Subtópico** representa o detalhamento de um tópico.
- A **Dificuldade** expressa a percepção pessoal do estudante sobre uma disciplina, em uma escala de 1 a 5.

## Regras e invariantes

- Toda disciplina, tópico e subtópico deve ter um nome não vazio de até 120 caracteres.
- A dificuldade pertence à disciplina e deve estar entre 1 e 5.
- Uma disciplina pode existir sem tópicos.
- Um tópico sempre pertence a uma disciplina.
- Um subtópico sempre pertence a um tópico.
- Excluir uma disciplina exclui seus tópicos e subtópicos.
- Excluir um tópico exclui seus subtópicos.
- A cor da disciplina é uma informação visual no formato hexadecimal `#RRGGBB`.

## Glossário

| Termo | Definição | Evitar |
| ----- | --------- | ------ |
| Disciplina | Área de conhecimento organizada pelo estudante | Matéria, curso |
| Tópico | Divisão de conteúdo de uma disciplina | Capítulo, módulo |
| Subtópico | Detalhamento de um tópico | Subitem |
| Dificuldade | Percepção pessoal do estudante, de 1 a 5 | Complexidade absoluta |
| Catálogo de estudos | Árvore completa de disciplinas, tópicos e subtópicos | Grade curricular |

## Fronteiras técnicas

- `app/` contém o cliente Flutter Web e consome a API por HTTP/JSON.
- `api/` contém a API Go e as regras de aplicação.
- MySQL é a fonte persistente dos dados.
- O contrato HTTP é documentado em `api/docs/openapi.yaml`.
- O domínio não deve depender de Flutter, HTTP ou MySQL.

## Decisões futuras ainda em aberto

- Como representar sessões e tempo de estudo.
- Como agendar e recalcular revisões.
- Como medir domínio, progresso e cobertura de conteúdo.
- Como representar concursos, editais e relações entre um tópico e diferentes provas.
- Como autenticar usuários e separar seus catálogos.
