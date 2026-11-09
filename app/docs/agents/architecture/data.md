# Camada data

## Processo

1. Leia OpenAPI e o contrato de `Repository`; identifique endpoint, entrada, resposta, status e erro de cada operação.
2. Crie um `ApiModel` por formato externo e converta-o para `domain`; mapas JSON permanecem em `data`.
3. Implemente `ApiService` sem estado de negócio, com cliente e endereço injetáveis e status validados.
4. Implemente o `Repository` como fonte de verdade: conversão, cache, refresh após mutação e tradução de erros.
5. Ao mudar payload, atualize API, OpenAPI, API models e fixtures juntos.
6. Teste service e repository separadamente.

## Regras

- JSON usa português sem acentos: `nome`, `dificuldade`, `cor`, `topicos`, `obrigatorio`, `subtopicos`, `erro`.
- Leia campos obrigatórios com `core/data/serializacao/leitor_json.dart`; leitores genéricos novos ficam ali com testes.
- `ApiModel` conhece JSON e conversão; `domain` conhece apenas estado válido.
- `ApiService` centraliza JSON, headers, status e `erro`; o chamador gerencia `http.Client`.
- `Repository` retorna domínio e coleções imutáveis, invalida/atualiza cache e preserva a causa de falhas externas.
- Repositories não dependem entre si; combine-os em use case ou view model.

## Conclusão

- Nenhum mapa JSON ou API model sai de `data`.
- Requests e responses modificados têm testes.
- OpenAPI descreve os payloads testados e resolve todas as referências.
- `flutter analyze`, testes compartilhados e da funcionalidade passam.
