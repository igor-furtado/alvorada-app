# Issue tracker: GitHub

Issues e especificações deste repositório são armazenados como GitHub Issues. Use o CLI `gh` para todas as operações.

## Conventions

- **Criar uma issue**: `gh issue create --title "..." --body "..."`. Use heredoc para descrições com múltiplas linhas.
- **Consultar uma issue**: `gh issue view <number> --comments`, incluindo labels e comentários relevantes.
- **Listar issues**: `gh issue list --state open --json number,title,body,labels,comments` com filtros apropriados de estado e label.
- **Comentar**: `gh issue comment <number> --body "..."`.
- **Adicionar ou remover labels**: `gh issue edit <number> --add-label "..."` ou `gh issue edit <number> --remove-label "..."`.
- **Encerrar**: `gh issue close <number> --comment "..."`.

O repositório deve ser inferido pelo remote Git. Enquanto não houver um remote configurado, informe `--repo <owner>/<repo>` nos comandos `gh`.

## Pull requests as a triage surface

**PRs as a request surface: no.** _(Altere para `yes` caso o projeto passe a tratar pull requests externos como solicitações.)_

Quando habilitado, use os equivalentes `gh pr` e aplique os mesmos labels e estados utilizados nas issues. Como GitHub Issues e pull requests compartilham a mesma sequência numérica, confirme o tipo do item antes de atuar.

## When a skill says "publish to the issue tracker"

Crie uma GitHub Issue.

## When a skill says "fetch the relevant ticket"

Execute `gh issue view <number> --comments`.

## Wayfinding operations

- **Mapa**: uma única issue com o label `wayfinder:map`, contendo notas, decisões tomadas e pontos ainda incertos.
- **Ticket filho**: uma issue vinculada ao mapa como GitHub sub-issue. Quando sub-issues não estiverem disponíveis, use uma task list no mapa e adicione `Part of #<map>` ao início do ticket.
- **Tipos de ticket**: use `wayfinder:research`, `wayfinder:prototype`, `wayfinder:grilling` ou `wayfinder:task`.
- **Bloqueios**: prefira as dependências nativas do GitHub. Como fallback, adicione `Blocked by: #<n>` ao início da descrição.
- **Próximo trabalho**: escolha o primeiro ticket aberto na ordem do mapa que não tenha bloqueios abertos nem responsável.
- **Assumir um ticket**: `gh issue edit <n> --add-assignee @me`.
- **Resolver**: registre a resposta em um comentário, encerre a issue e atualize as decisões no mapa.
