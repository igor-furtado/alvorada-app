import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('usa a mesma altura padrão dos campos de texto', (tester) async {
    const buttonKey = ValueKey('button');
    const inputKey = ValueKey('input');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 240,
                  child: AppTextInput(key: inputKey),
                ),
                AppButton(
                  key: buttonKey,
                  label: 'Salvar',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final inputHeight = tester.getSize(find.byKey(inputKey)).height;
    final buttonHeight = tester.getSize(find.byKey(buttonKey)).height;

    expect(buttonHeight, inputHeight);
    expect(buttonHeight, AppTheme.light.extension<AppTokens>()!.layout.controlHeight);
  });

  testWidgets('mantém a mesma altura interna com e sem ícone', (tester) async {
    const plainInputKey = ValueKey('plain-input');
    const iconInputKey = ValueKey('icon-input');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 240,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextInput(key: plainInputKey),
                  AppTextInput(
                    key: iconInputKey,
                    prefixIcon: AppIcon(AppIcons.search),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final plainInputHeight = _inputContainerHeight(tester, plainInputKey);
    final iconInputHeight = _inputContainerHeight(tester, iconInputKey);
    final controlHeight = AppTheme.light.extension<AppTokens>()!.layout.controlHeight;
    final plainField = tester.widget<TextField>(
      find.descendant(
        of: find.byKey(plainInputKey),
        matching: find.byType(TextField),
      ),
    );
    final plainDecoration = plainField.decoration!;

    expect(plainInputHeight, controlHeight);
    expect(iconInputHeight, controlHeight);
    expect(plainDecoration.prefixIcon, isNotNull);
    expect(
      plainDecoration.prefixIconConstraints,
      BoxConstraints.tightFor(width: 0, height: controlHeight),
    );
  });
}

double _inputContainerHeight(WidgetTester tester, ValueKey<String> key) {
  final editable = find.descendant(
    of: find.byKey(key),
    matching: find.byType(EditableText),
  );
  final container = InputDecorator.containerOf(tester.element(editable));

  return container!.size.height;
}
