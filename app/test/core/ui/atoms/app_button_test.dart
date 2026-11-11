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
}
