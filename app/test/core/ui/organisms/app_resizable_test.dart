import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('desenha divisor contínuo, alça e redimensiona na horizontal', (tester) async {
    await _pumpResizable(
      tester,
      AppResizable(
        first: Container(key: const ValueKey('first-pane')),
        second: Container(key: const ValueKey('second-pane')),
      ),
    );

    final divider = find.byKey(const ValueKey('app-resizable-divider'));
    final indicator = find.byKey(const ValueKey('app-resizable-handle-indicator'));
    final firstPane = find.byKey(const ValueKey('first-pane'));
    final initialWidth = tester.getSize(firstPane).width;

    expect(tester.getSize(divider), const Size(1, 200));
    expect(tester.getSize(indicator), const Size(4, 24));

    await tester.drag(find.bySemanticsLabel('Redimensionar painéis'), const Offset(40, 0));
    await tester.pump();

    expect(tester.getSize(firstPane).width, greaterThan(initialWidth));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final widthBeforeKeyboard = tester.getSize(firstPane).width;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    expect(tester.getSize(firstPane).width, greaterThan(widthBeforeKeyboard));
  });

  testWidgets('rotaciona divisor e alça na orientação vertical', (tester) async {
    await _pumpResizable(
      tester,
      AppResizable(
        direction: Axis.vertical,
        first: Container(),
        second: Container(),
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('app-resizable-divider'))),
      const Size(400, 1),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('app-resizable-handle-indicator'))),
      const Size(24, 4),
    );
  });

  testWidgets('permite ocultar a alça sem remover o divisor acessível', (tester) async {
    await _pumpResizable(
      tester,
      AppResizable(
        withHandle: false,
        first: Container(),
        second: Container(),
      ),
    );

    expect(find.byKey(const ValueKey('app-resizable-divider')), findsOneWidget);
    expect(find.byKey(const ValueKey('app-resizable-handle-indicator')), findsNothing);
    expect(find.bySemanticsLabel('Redimensionar painéis'), findsOneWidget);
  });
}

Future<void> _pumpResizable(WidgetTester tester, Widget child) => tester.pumpWidget(
  MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          height: 200,
          child: child,
        ),
      ),
    ),
  ),
);
