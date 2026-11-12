import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('alterna o conteúdo na variação sublinhada', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: AppTabs<String>(
            initialValue: 'edital',
            variant: AppTabsVariant.line,
            trailing: Text('Banca FGV'),
            items: [
              AppTabItem(value: 'edital', label: 'Edital', content: Text('Conteúdo do Edital')),
              AppTabItem(value: 'informacoes', label: 'Informações', content: Text('Dados do Concurso')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Conteúdo do Edital'), findsOneWidget);
    expect(find.text('Banca FGV'), findsOneWidget);

    await tester.tap(find.text('Informações'));
    await tester.pumpAndSettle();

    expect(find.text('Conteúdo do Edital'), findsNothing);
    expect(find.text('Dados do Concurso'), findsOneWidget);
  });

  testWidgets('permite controle externo da aba selecionada', (tester) async {
    var selected = 'edital';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: AppTabs<String>(
              initialValue: 'edital',
              value: selected,
              onChanged: (value) => setState(() => selected = value),
              items: const [
                AppTabItem(value: 'edital', label: 'Edital', content: Text('Edital ativo')),
                AppTabItem(value: 'topico', label: 'Tópico', content: Text('Tópico ativo')),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tópico'));
    await tester.pumpAndSettle();

    expect(selected, 'topico');
    expect(find.text('Tópico ativo'), findsOneWidget);
  });

  testWidgets('percorre as abas com as setas e move o foco', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: AppTabs<String>(
            initialValue: 'edital',
            items: [
              AppTabItem(value: 'edital', label: 'Edital', content: Text('Edital ativo')),
              AppTabItem(value: 'topico', label: 'Tópico', content: Text('Tópico ativo')),
            ],
          ),
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();

    expect(find.text('Tópico ativo'), findsOneWidget);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'AppTabs Tópico');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();

    expect(find.text('Edital ativo'), findsOneWidget);
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'AppTabs Edital');
  });
}
