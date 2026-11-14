import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/molecules/app_combobox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const frameworks = ['Next.js', 'SvelteKit', 'Nuxt.js', 'Remix', 'Astro'];

  testWidgets('filtra sugestões sem diferenciar acentos', (tester) async {
    await tester.pumpWidget(
      _testApp(
        AppCombobox<String>(
          options: const ['Direito Constitucional', 'Língua Portuguesa', 'Raciocínio Lógico'],
          displayStringForOption: _identity,
          placeholder: 'Selecione uma disciplina',
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byType(EditableText));
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'raciocinio');
    await tester.pump();

    expect(find.text('Raciocínio Lógico'), findsOneWidget);
    expect(find.text('Língua Portuguesa'), findsNothing);

    await tester.enterText(find.byType(EditableText), 'inexistente');
    await tester.pump();

    expect(find.text('Nenhum resultado encontrado.'), findsOneWidget);
  });

  testWidgets('seleciona e limpa um valor controlado', (tester) async {
    String? selected;

    await tester.pumpWidget(
      _testApp(
        StatefulBuilder(
          builder: (context, setState) => AppCombobox<String>(
            options: frameworks,
            displayStringForOption: _identity,
            value: selected,
            showClear: true,
            onChanged: (value) => setState(() => selected = value),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(EditableText));
    await tester.pump();
    await tester.tap(find.text('SvelteKit'));
    await tester.pump();

    expect(selected, 'SvelteKit');
    expect(tester.widget<EditableText>(find.byType(EditableText)).controller.text, 'SvelteKit');

    await tester.tap(find.byType(EditableText));
    await tester.pump();
    expect(find.text('Astro'), findsOneWidget);

    await tester.tap(find.byTooltip('Limpar seleção'));
    await tester.pump();

    expect(selected, isNull);
  });

  testWidgets('não abre sugestões quando está desabilitado', (tester) async {
    await tester.pumpWidget(
      _testApp(
        AppCombobox<String>(
          options: frameworks,
          displayStringForOption: _identity,
          disabled: true,
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.byType(EditableText), warnIfMissed: false);
    await tester.pump();

    expect(find.text('Next.js'), findsNothing);
    expect(tester.widget<EditableText>(find.byType(EditableText)).readOnly, isTrue);
  });

  testWidgets('mantém chips e lista aberta na seleção múltipla', (tester) async {
    var selected = <String>['Next.js'];

    await tester.pumpWidget(
      _testApp(
        StatefulBuilder(
          builder: (context, setState) => AppCombobox<String>.multiple(
            options: frameworks,
            displayStringForOption: _identity,
            values: selected,
            showClear: true,
            onValuesChanged: (values) => setState(() => selected = values),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(EditableText));
    await tester.pump();
    await tester.tap(find.text('SvelteKit'));
    await tester.pump();

    expect(selected, ['Next.js', 'SvelteKit']);
    expect(find.text('Astro'), findsOneWidget);
    expect(find.byTooltip('Remover Next.js'), findsOneWidget);
    expect(find.byTooltip('Remover SvelteKit'), findsOneWidget);

    await tester.tap(find.byTooltip('Remover Next.js'));
    await tester.pump();
    expect(selected, ['SvelteKit']);

    await tester.tap(find.byTooltip('Limpar seleção'));
    await tester.pump();
    expect(selected, isEmpty);
  });

  testWidgets('permite navegar e selecionar usando o teclado', (tester) async {
    String? selected;

    await tester.pumpWidget(
      _testApp(
        StatefulBuilder(
          builder: (context, setState) => AppCombobox<String>(
            options: frameworks,
            displayStringForOption: _identity,
            value: selected,
            onChanged: (value) => setState(() => selected = value),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(EditableText));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(selected, 'SvelteKit');
  });
}

String _identity(String value) => value;

Widget _testApp(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(
    body: Center(
      child: SizedBox(width: 320, child: child),
    ),
  ),
);
