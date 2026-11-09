# Acessibilidade Web

WCAG 2.2 AA bloqueia a entrega. Referências: [design](https://docs.flutter.dev/ui/accessibility/ui-design-and-styling), [Web](https://docs.flutter.dev/ui/accessibility/web-accessibility) e [testes Flutter](https://docs.flutter.dev/ui/accessibility/accessibility-testing).

## Regras

- Contraste: texto comum 4,5:1; texto grande, foco e componente 3:1. Teste claro e escuro com `AppAccessibility`.
- Papéis cromáticos: `primary` destaque/preenchimento; `actionForeground` texto/ícone; `border` separação; `controlOutline` controle; `focusRing` foco; `errorForeground` erro textual.
- Semântica: preserve a semântica Material; nomeie ícone acionável; exclua ícone decorativo; una label/controle; anuncie erro, loading, snackbar e novo lote.
- Teclado: Tab segue ordem visual; setas percorrem rádios; Esc fecha modal; fechar restaura foco. Região composta usa `FocusTraversalGroup`.
- Foco: contorno `focusRing`, 2 dp, perceptível sem depender somente de cor.
- Toque: alvo mínimo 48×48 dp.
- Texto: 200%; reorganize antes de truncar.
- Movimento: passe duração por `context.motionDuration`; redução de movimento produz duração zero.
- Status: combine texto/ícone com cor.

## Aceite

- `meetsGuideline` cobre contraste, rótulo e alvo nas telas alteradas.
- Teste de Semantics encontra nome, papel, estado e ação.
- Teste a 200% não produz overflow.
- Toda combinação semântica de cor passa no limiar aplicável em `design_tokens_test.dart`.
