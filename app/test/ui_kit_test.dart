import 'package:estudos_app/src/core/content/app_messages.dart';
import 'package:estudos_app/src/core/theme/app_shad_theme.dart';
import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  Widget subject(Widget child) => ShadApp.custom(
    theme: AppShadTheme.light,
    appBuilder: (context) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    ),
  );

  testWidgets('AppButton executa a ação e respeita a variante', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      subject(
        AppButton(
          label: 'Continuar',
          variant: AppButtonVariant.outline,
          onPressed: () => taps++,
        ),
      ),
    );

    expect(find.byType(ShadButton), findsOneWidget);
    await tester.tap(find.text('Continuar'));
    expect(taps, 1);
  });

  testWidgets('AppButton desabilita a ação durante carregamento', (tester) async {
    await tester.pumpWidget(
      subject(
        AppButton(label: 'Salvar', loading: true, onPressed: () {}),
      ),
    );

    final button = tester.widget<ShadButton>(find.byType(ShadButton));
    expect(button.enabled, isFalse);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AppMetricOverview apresenta os dados recebidos', (tester) async {
    await tester.pumpWidget(
      subject(
        const AppMetricOverview(
          items: [
            AppMetricData(icon: AppIcons.statistics, value: '24', label: 'Registros ativos'),
          ],
        ),
      ),
    );

    expect(find.text('24'), findsOneWidget);
    expect(find.text('Registros ativos'), findsOneWidget);
  });

  testWidgets('AppFormField expõe label, ajuda e entrada', (tester) async {
    await tester.pumpWidget(
      subject(
        const AppFormField(
          label: 'Disciplina',
          placeholder: 'Nome da disciplina',
          helperText: 'Use o nome do edital.',
        ),
      ),
    );

    expect(find.text('Disciplina'), findsOneWidget);
    expect(find.text('Nome da disciplina'), findsOneWidget);
    expect(find.text('Use o nome do edital.'), findsOneWidget);
  });

  testWidgets('AppInfiniteListView apresenta itens e encerra a paginação', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SizedBox(
            height: AppTokens.light().sizes.overviewPanel,
            child: AppInfiniteListView<int>(
              loadPage: (_) async => const AppInfinitePage(items: [1, 2]),
              itemBuilder: (context, item, index) => Text('Item $item'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.text(AppMessages.noMoreResults), findsOneWidget);
  });
}
