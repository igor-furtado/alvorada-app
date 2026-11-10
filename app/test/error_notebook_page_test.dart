import 'package:estudos_app/src/app.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('abre Caderno de Erros pela navegação principal', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EstudosApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('shell-destination-5')));
    await tester.pumpAndSettle();

    expect(find.text('Em revisão'), findsOneWidget);
    expect(find.text('Diagnóstico antes do remédio'), findsOneWidget);
    expect(find.text('A regra certa, com minhas palavras'), findsWidgets);
    expect(find.text('Por que eu caí'), findsWidgets);
    expect(find.text('Conteúdo'), findsWidgets);
    expect(find.text('Leitura'), findsWidgets);
    expect(find.text('Pressa'), findsWidgets);
    expect(find.text('Armadilha'), findsWidgets);
  });

  testWidgets('formulário exige a Regra certa e o Por que eu caí', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EstudosApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('shell-destination-5')));
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(AppButton, 'Registrar erro'));
    await tester.pumpAndSettle();

    final dialog = find.byType(Dialog);
    expect(
      find.descendant(of: dialog, matching: find.text('Tipo do erro')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('Banca e ano')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: dialog,
        matching: find.text('A regra certa, com minhas palavras *'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('Por que eu caí *')),
      findsOneWidget,
    );

    final submit = find.widgetWithText(
      AppButton,
      'Salvar e programar Revisões',
    );
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(
      find.text('Escreva com suas palavras para concluir o registro.'),
      findsNWidgets(2),
    );
  });
}
