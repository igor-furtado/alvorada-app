# Jornadas do produto

Estes são os únicos fluxos de produto disponíveis para extensão. Cada diagrama mostra o caminho feliz e o desvio recuperável.

## Alvorada do dia

```mermaid
flowchart LR
  A[Abrir Hoje] --> B{Domingo?}
  B -- sim --> C[Domingo protegido]
  B -- não --> D[Ver Alvorada] --> E[Iniciar Turno]
  E --> F{Disponível?}
  F -- sim --> G[Executar]
  F -- não --> H[Feedback inline]
```

## Esta semana

```mermaid
flowchart LR
  A[Abrir Semana] --> B[Consultar Turnos] --> C[Ajustar]
  C --> D{Salvar?}
  D -- não --> B
  D -- sim --> E{Falhou?}
  E -- sim --> C
  E -- não --> B
```

## Horizontes e Edital

```mermaid
flowchart LR
  A[Abrir Horizontes] --> B{Existe?}
  B -- não --> C[Criar] --> D[Abrir Horizonte]
  B -- sim --> D
  D --> E[Abrir Edital] --> F[Editar]
  F --> G{Salvar?}
  G -- não --> H[Proteger abandono]
  G -- sim --> I[Persistir]
  I --> J{Excluir?} --> K[Confirmar impacto]
```

## Revisões programadas

```mermaid
flowchart LR
  A[Abrir Revisões] --> B[Buscar ou filtrar] --> C{Resultados?}
  C -- não --> D[Vazio com ação]
  C -- sim --> E[Abrir instrução] --> F[Começar]
  F --> G{Concluiu?}
  G -- não --> E
  G -- sim --> H[Atualizar ciclo]
```

## Caderno de Erros

```mermaid
flowchart LR
  A[Abrir Caderno] --> B{Registrar ou revisar?}
  B -- registrar --> C[Diagnosticar] --> D{Válido?}
  D -- não --> E[Focar erro] --> C
  D -- sim --> F[Salvar e programar]
  B -- revisar --> G[Abrir registro] --> H[Concluir revisão]
  H --> I{Ciclo encerrado?}
  I -- sim --> J[Arquivo]
  I -- não --> K[Caderno ativo]
```
