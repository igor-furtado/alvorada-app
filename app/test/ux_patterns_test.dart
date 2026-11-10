import 'package:estudos_app/src/app.dart';
import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    expect(find.byKey(const ValueKey('shell-destination-0')), findsOneWidget);
    expect(find.text('Ir para uma área…'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    tester.view.physicalSize = const Size(1024, 900);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('shell-destination-2')), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);

    final todayItem = tester.widget<AppAccessibleIconButton>(
      find.byKey(const ValueKey('shell-destination-0')),
    );
    expect(todayItem.selected, isTrue);
  });

  testWidgets('preserva o estado de uma branch ao trocar de área', (tester) async {
    await setWindow(tester, const Size(1440, 1000));
    await tester.tap(find.byKey(const ValueKey('shell-destination-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Novo Concurso'));
    await tester.pumpAndSettle();

    final fields = find.descendant(
      of: find.byType(AppDialog),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(fields.at(0), 'Instituto Aurora');
    await tester.enterText(fields.at(1), 'Analista');
    await tester.enterText(fields.at(2), 'Banca Exemplo');
    await tester.tap(find.widgetWithText(AppButton, 'Criar Concurso'));
    await tester.pumpAndSettle();
    expect(find.text('Instituto Aurora'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('shell-destination-4')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('shell-destination-2')));
    await tester.pumpAndSettle();

    expect(find.text('Instituto Aurora'), findsOneWidget);
  });

  testWidgets('barra de comando navega para uma área', (tester) async {
    await setWindow(tester, const Size(1024, 900));

    await tester.enterText(find.byType(TextFormField).first, 'Disciplinas');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(
      find.text('Organize Tópicos e Subtópicos sem perder o contexto do catálogo.'),
      findsOneWidget,
    );
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).first).controller?.text,
      isEmpty,
    );
    expect(find.byTooltip('Limpar busca'), findsNothing);
  });

  testWidgets('limpa o comando ao selecionar outra área', (tester) async {
    await setWindow(tester, const Size(1024, 900));

    await tester.enterText(find.byType(TextFormField).first, 'Direito');
    await tester.tap(find.byKey(const ValueKey('shell-destination-3')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).first).controller?.text,
      isEmpty,
    );
    expect(find.byTooltip('Limpar busca'), findsNothing);
  });

  testWidgets('alterna entre os temas claro e escuro pelo shell', (tester) async {
    await setWindow(tester, const Size(1024, 900));

    final initialBrightness = Theme.of(tester.element(find.byKey(const ValueKey('theme-toggle')))).brightness;
    await tester.tap(find.byKey(const ValueKey('theme-toggle')));
    await tester.pumpAndSettle();

    final changedBrightness = Theme.of(tester.element(find.byKey(const ValueKey('theme-toggle')))).brightness;
    expect(changedBrightness, isNot(initialBrightness));
    expect(
      find.byTooltip(changedBrightness == Brightness.dark ? 'Usar tema claro' : 'Usar tema escuro'),
      findsOneWidget,
    );

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('theme-toggle')), findsOneWidget);
  });

  testWidgets('componentes básicos atendem rótulo e densidade shadcn', (tester) async {
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
    expect(tester.getSize(find.byType(AppButton)).height, 32);
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
