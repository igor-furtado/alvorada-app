import 'package:estudos_app/src/app.dart';
import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> setWindow(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const EstudosApp());
    await tester.pumpAndSettle();
  }

  testWidgets('adapta a navegação à largura disponível', (tester) async {
    await setWindow(tester, const Size(390, 844));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Caderno'), findsOneWidget);

    tester.view.physicalSize = const Size(720, 900);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    tester.view.physicalSize = const Size(1024, 900);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Concursos'), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('preserva o estado de uma branch ao trocar de área', (tester) async {
    await setWindow(tester, const Size(1440, 1000));
    await tester.tap(find.widgetWithText(ListTile, 'Concursos'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Novo Concurso'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Instituto Aurora');
    await tester.enterText(fields.at(1), 'Analista');
    await tester.enterText(fields.at(2), 'Banca Exemplo');
    await tester.tap(find.text('Criar Concurso'));
    await tester.pumpAndSettle();
    expect(find.text('Instituto Aurora'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'Revisões'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Concursos'));
    await tester.pumpAndSettle();

    expect(find.text('Instituto Aurora'), findsOneWidget);
  });

  testWidgets('componentes básicos atendem rótulo e alvo de toque', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppButton(label: 'Salvar alterações', onPressed: () {}),
        ),
      ),
    );

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('layout compacto suporta texto a 200%', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await setWindow(tester, const Size(390, 844));

    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
