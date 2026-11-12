---
status: accepted
---

# Compor o Edital por vínculos com Tópicos

Cada Concurso possui um único Edital, que representa o recorte estudável vigente do edital de abertura. A única associação persistida para compor esse recorte é entre Concurso e Tópico do catálogo. A presença de uma Disciplina é derivada dos Tópicos vinculados, e sua Revisão de Véspera aparece automaticamente sem vínculo próprio.

Adicionar uma Disciplina no editor é um atalho em lote: vincula todos os seus Tópicos comuns existentes naquele momento e ignora vínculos já presentes. Tópicos criados depois não entram automaticamente. Remover o último Tópico comum retira também a Disciplina derivada e sua Revisão de Véspera do Edital. Disciplina ou Tópico em uso por algum Edital não pode ser excluído do catálogo.

O conceito de Subtópico foi removido do produto, da API e da persistência. O Edital não mantém ordem própria nesta decisão.

Como o projeto possui somente o ambiente local e os dados de Subtópicos não têm mais representação válida no domínio, a remoção das tabelas legadas é uma exceção deliberadamente destrutiva à regra geral de preservação de dados em migrações. A decisão foi autorizada explicitamente para eliminar o conceito por completo; a operação continua idempotente e retomável.

## Alternativa considerada

Persistir vínculos separados para Disciplina e Tópico permitiria estados parcialmente independentes, mas criaria duplicidade e risco de inconsistência. Derivar a Disciplina mantém o Tópico como única fonte de verdade do recorte.
