import 'package:estudos_app/src/app.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('abre Esta semana pela navegação principal', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EstudosApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('shell-destination-1')));
    await tester.pumpAndSettle();

    expect(find.text('2 a 8 de novembro · Consolidação'), findsOneWidget);
    expect(find.text('8 de 14 horas realizadas'), findsOneWidget);
    expect(find.text('Disciplina principal'), findsOneWidget);
    expect(find.text('Revisões programadas'), findsOneWidget);
    expect(find.textContaining('Domingo protegido'), findsOneWidget);
    expect(find.text('Ver Hoje'), findsOneWidget);
    expect(
      find.textContaining(RegExp('retorno', caseSensitive: false)),
      findsNothing,
    );
  });

  testWidgets('permite iniciar o ajuste da semana no celular', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const EstudosApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Semana').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Ajustar semana'));
    await tester.pumpAndSettle();

    expect(find.text('Ajustar esta semana'), findsOneWidget);
    expect(find.text('Tive menos tempo'), findsOneWidget);
    expect(find.text('Tenho tempo extra'), findsOneWidget);
    expect(find.textContaining('domingo em dívida'), findsOneWidget);
  });
}
