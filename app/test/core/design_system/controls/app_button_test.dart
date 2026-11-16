import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

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
    expect(buttonHeight, AppTheme.light.extension<AppTokens>()!.layout.inputHeight);
    expect(buttonHeight, 48);
  });

  testWidgets('responde no toque para baixo com escala sutil', (tester) async {
    const buttonKey = ValueKey('press-button');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: AppButton(
              key: buttonKey,
              label: 'Continuar',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(tester.getCenter(find.byKey(buttonKey)));
    await tester.pump();

    final scale = tester.widget<AnimatedScale>(
      find.descendant(of: find.byKey(buttonKey), matching: find.byType(AnimatedScale)),
    );
    expect(scale.scale, .98);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('diferencia ações de textos de conteúdo pela tipografia', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: AppButton(
              label: 'Salvar Tópicos',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    final label = tester.widget<Text>(find.text('Salvar Tópicos'));

    expect(label.style?.fontSize, 13);
    expect(label.style?.fontWeight, FontWeight.w600);
    expect(label.style?.height, 1.15);
    expect(label.style?.letterSpacing, .3);
  });

  testWidgets('mantém a mesma altura dos campos com e sem ícone', (tester) async {
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
    final controlHeight = AppTheme.light.extension<AppTokens>()!.layout.inputHeight;
    final horizontalPadding = AppTheme.light.extension<AppTokens>()!.layout.inputHPadding;
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
      BoxConstraints.tightFor(width: horizontalPadding, height: controlHeight),
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
