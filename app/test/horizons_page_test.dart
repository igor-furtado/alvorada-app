import 'package:estudos_app/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('abre Horizontes pela navegação principal', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EstudosApp());
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ListTile, 'Véspera'), findsNothing);

    await tester.tap(find.text('Horizontes').first);
    await tester.pumpAndSettle();

    expect(find.text('Analista Legislativo'), findsOneWidget);
    expect(find.text('Horizonte principal'), findsWidgets);
    expect(find.text('Tópicos compartilhados'), findsWidgets);
    expect(find.text('Como o plano decide'), findsOneWidget);
    expect(find.text('Esta semana'), findsWidgets);
    expect(
      find.textContaining(RegExp('pauta', caseSensitive: false)),
      findsNothing,
    );
    expect(
      find.textContaining(RegExp('folhinha', caseSensitive: false)),
      findsNothing,
    );
  });

  testWidgets('mostra o início do fluxo de um novo Horizonte', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EstudosApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Horizontes').first);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Novo Horizonte'));
    await tester.pumpAndSettle();

    expect(find.text('Concurso-alvo'), findsOneWidget);
    expect(find.text('Data da prova'), findsOneWidget);
    expect(
      find.text('Sem data? O próximo passo será organizar o Edital.'),
      findsOneWidget,
    );
  });

  testWidgets('mantém Revisão de Véspera como último Tópico obrigatório', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EstudosApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Horizontes').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Ver Edital').first);
    await tester.pumpAndSettle();

    expect(find.text('O conteúdo permanece no material'), findsOneWidget);
    expect(find.text('Revisão de Véspera'), findsNWidgets(3));
    expect(
      find.byTooltip('Tópico obrigatório: não pode ser excluído'),
      findsNWidgets(3),
    );
    expect(find.byTooltip('Excluir Tópico'), findsNWidgets(9));
    expect(
      find.textContaining('O Plano pode programar o Tópico perto da prova'),
      findsOneWidget,
    );

    final lastOrdinaryTopic = find.byKey(
      const ValueKey(
        'topic-Direito Constitucional-Controle de constitucionalidade',
      ),
    );
    final requiredTopic = find.byKey(
      const ValueKey('required-eve-review-Direito Constitucional'),
    );
    expect(
      tester.getTopLeft(requiredTopic).dy,
      greaterThan(tester.getTopLeft(lastOrdinaryTopic).dy),
    );

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(find.text('O conteúdo permanece no material'), findsOneWidget);
  });
}
