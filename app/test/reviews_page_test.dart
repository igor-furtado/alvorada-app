import 'package:estudos_app/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('abre Revisões pela navegação principal', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EstudosApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Revisões').first);
    await tester.pumpAndSettle();

    expect(find.text('Revisões para hoje'), findsWidgets);
    expect(find.text('Revisão de 1 dia'), findsOneWidget);
    expect(find.text('Revisão de 7 dias'), findsOneWidget);
    expect(find.text('Revisão de 30 dias'), findsOneWidget);
    expect(find.text('33 min'), findsOneWidget);
    expect(
      find.textContaining(RegExp('retorno', caseSensitive: false)),
      findsNothing,
    );
  });

  testWidgets('explica as Revisões no celular', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EstudosApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Revisões').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Como funciona'));
    await tester.pumpAndSettle();

    expect(find.text('Como funcionam as Revisões'), findsOneWidget);
    expect(find.textContaining('1, 7 e 30 dias'), findsOneWidget);
  });
}
