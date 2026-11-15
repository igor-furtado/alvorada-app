import 'package:estudos_app/core/design_system/design_system.dart';
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

  testWidgets('mantém abas e conteúdo auxiliar roláveis no compacto com texto ampliado', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: AppTabs<String>(
            initialValue: 'edital',
            variant: AppTabsVariant.line,
            trailing: Text('Banca FGV · prova em Recife · fevereiro de 2027'),
            items: [
              AppTabItem(value: 'edital', label: 'Edital', content: Text('Conteúdo do Edital')),
              AppTabItem(value: 'informacoes', label: 'Informações', content: Text('Dados do Concurso')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Conteúdo do Edital'), findsOneWidget);
    expect(find.textContaining('Banca FGV'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
