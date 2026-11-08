import 'package:estudos_app/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> openHorizons(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EstudosApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Horizontes').first);
    await tester.pumpAndSettle();
  }

  testWidgets('prioriza as informações essenciais dos Horizontes', (
    tester,
  ) async {
    await openHorizons(tester);

    expect(find.text('Tribunal Regional Federal da 5ª Região'), findsOneWidget);
    expect(
      find.text('Técnico Judiciário — Área Administrativa'),
      findsOneWidget,
    );
    expect(find.text('FCC'), findsOneWidget);
    expect(find.text('13 dez. 2026'), findsOneWidget);
    expect(find.text('36'), findsOneWidget);
    expect(find.text('Avanço no Edital'), findsNWidgets(3));
    expect(find.text('A próxima prova é em 36 dias'), findsOneWidget);

    expect(find.textContaining('Horizontes ativos'), findsNothing);
    expect(find.textContaining('Tópicos compartilhados'), findsNothing);
    expect(find.textContaining('Disponíveis por semana'), findsNothing);
    expect(find.textContaining('disciplinas ·'), findsNothing);
  });

  testWidgets('abre os fluxos de adicionar e consultar o Edital', (
    tester,
  ) async {
    await openHorizons(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Novo Horizonte'));
    await tester.pumpAndSettle();
    expect(find.text('Órgão ou instituição *'), findsOneWidget);
    expect(find.text('Cargo *'), findsOneWidget);
    expect(find.text('Banca'), findsWidgets);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Abrir Edital').first);
    await tester.pumpAndSettle();
    expect(find.text('Edital'), findsOneWidget);
    expect(find.text('Língua Portuguesa'), findsOneWidget);
  });

  testWidgets('abre os detalhes pelo card e volta pela rota superior', (
    tester,
  ) async {
    await openHorizons(tester);

    await tester.tap(find.text('Tribunal Regional Federal da 5ª Região').first);
    await tester.pumpAndSettle();

    expect(find.text('Nova Disciplina'), findsOneWidget);
    expect(find.text('Língua Portuguesa'), findsOneWidget);
    expect(find.text('PESO NO EDITAL'), findsOneWidget);
    expect(find.textContaining('Buscar disciplina'), findsNothing);
    expect(find.textContaining('Ordenar:'), findsNothing);
    expect(find.byType(TextFormField), findsNWidgets(8));
    expect(find.byTooltip('Remover Disciplina'), findsNWidgets(8));
    expect(find.widgetWithText(TextButton, 'Horizontes'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Horizontes'));
    await tester.pumpAndSettle();

    expect(find.text('A próxima prova é em 36 dias'), findsOneWidget);
    expect(find.text('Informações da prova'), findsNothing);
  });

  testWidgets('abre Tópicos da Disciplina e volta ao Horizonte pela rota', (
    tester,
  ) async {
    await openHorizons(tester);

    await tester.tap(find.text('Tribunal Regional Federal da 5ª Região').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Língua Portuguesa'));
    await tester.pumpAndSettle();

    expect(find.text('EDITAL VERTICALIZADO'), findsOneWidget);
    expect(find.text('0 de 19 concluídos'), findsOneWidget);
    expect(find.text('Compreensão e interpretação de textos'), findsOneWidget);
    expect(find.text('Revisão de Véspera'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('discipline-name')),
      'Português Geral',
    );
    await tester.enterText(
      find.byKey(const ValueKey('discipline-weight')),
      '30',
    );
    await tester.enterText(
      find.byKey(const ValueKey('topic-1')),
      'Interpretação textual',
    );
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();

    expect(find.text('Português Geral'), findsWidgets);
    expect(find.text('Interpretação textual'), findsOneWidget);
    expect(find.text('1 de 19 concluídos'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'TRF da 5ª Região'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'TRF da 5ª Região'));
    await tester.pumpAndSettle();

    expect(find.text('Nova Disciplina'), findsOneWidget);
    expect(find.text('EDITAL VERTICALIZADO'), findsNothing);
  });

  testWidgets('mantém a linha do tempo legível no celular', (tester) async {
    await openHorizons(tester);

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();

    expect(find.text('Horizontes'), findsWidgets);
    expect(find.text('A próxima prova é em 36 dias'), findsOneWidget);
    expect(find.text('TRF da 5ª Região'), findsOneWidget);
    expect(find.byTooltip('Próxima variante'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
