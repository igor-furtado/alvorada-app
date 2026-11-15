import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('exibe a anatomia padrão e aciona a ação', (tester) async {
    var primaryTaps = 0;

    await _pumpStateView(
      tester,
      AppStateView(
        variant: AppStateVariant.empty,
        title: 'Nenhum Concurso ainda',
        message: 'Comece adicionando o primeiro.',
        actionLabel: 'Criar Concurso',
        onAction: () => primaryTaps++,
      ),
    );

    expect(find.byIcon(AppIcons.folderDashed), findsOneWidget);
    expect(find.text('Nenhum Concurso ainda'), findsOneWidget);
    expect(find.text('Comece adicionando o primeiro.'), findsOneWidget);
    await tester.tap(find.text('Criar Concurso'));

    expect(primaryTaps, 1);
  });

  testWidgets('permite substituir o ícone padrão', (tester) async {
    await _pumpStateView(
      tester,
      const AppStateView(
        variant: AppStateVariant.empty,
        icon: AppIcons.bookText,
        title: 'Pessoa offline',
        message: 'Tente novamente mais tarde.',
      ),
    );

    expect(find.byIcon(AppIcons.bookText), findsOneWidget);
    expect(find.byIcon(AppIcons.folderDashed), findsNothing);
  });

  testWidgets('preserva o layout compacto com texto a 200%', (tester) async {
    await _pumpStateView(
      tester,
      AppStateView(
        variant: AppStateVariant.error,
        title: 'Não foi possível carregar',
        message: 'Tente novamente; seus dados foram preservados.',
        actionLabel: 'Tentar novamente',
        onAction: () {},
      ),
      width: 320,
      height: 560,
      textScaler: const TextScaler.linear(2),
    );

    expect(find.text('Não foi possível carregar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('anuncia estados que exigem atenção como região viva', (tester) async {
    await _pumpStateView(
      tester,
      const AppStateView(variant: AppStateVariant.error),
    );

    final liveRegion = tester.widget<Semantics>(
      find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.container && widget.properties.liveRegion == true,
      ),
    );

    expect(liveRegion.properties.liveRegion, isTrue);
  });
}

Future<void> _pumpStateView(
  WidgetTester tester,
  Widget child, {
  ThemeData? theme,
  double width = 800,
  double height = 600,
  TextScaler textScaler = TextScaler.noScaling,
}) => tester.pumpWidget(
  MaterialApp(
    theme: theme ?? AppTheme.light,
    home: MediaQuery(
      data: MediaQueryData(
        size: Size(width, height),
        textScaler: textScaler,
      ),
      child: Scaffold(
        body: SizedBox(
          width: width,
          height: height,
          child: child,
        ),
      ),
    ),
  ),
);
