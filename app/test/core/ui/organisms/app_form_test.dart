import 'dart:async';

import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('organiza os campos com o espaçamento padrão', (tester) async {
    const firstKey = ValueKey('first-field');
    const secondKey = ValueKey('second-field');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppForm(
            onSubmit: () async {},
            contentBuilder: (context, submitting, submit) => const [
              SizedBox(key: firstKey, height: 20),
              SizedBox(key: secondKey, height: 20),
            ],
            builder: (context, submitting, submit, content) => content,
          ),
        ),
      ),
    );

    final firstBottom = tester.getBottomLeft(find.byKey(firstKey)).dy;
    final secondTop = tester.getTopLeft(find.byKey(secondKey)).dy;
    final spacing = AppTheme.light.extension<AppTokens>()!.spacing.lg;

    expect(secondTop - firstBottom, spacing);
  });

  testWidgets('valida, foca o primeiro erro e bloqueia envios repetidos', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    final submission = Completer<void>();
    var submitCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppForm(
            firstInvalidFocusNode: () => focusNode,
            onSubmit: () {
              submitCount++;
              return submission.future;
            },
            contentBuilder: (context, submitting, submit) => [
              AppField(
                label: 'Nome',
                required: true,
                control: AppTextInput(
                  controller: controller,
                  focusNode: focusNode,
                  validator: (value) => value == null || value.isEmpty ? 'Informe o nome.' : null,
                  semanticLabel: 'Nome, obrigatório',
                ),
              ),
            ],
            builder: (context, submitting, submit, content) => Column(
              children: [
                content,
                AppButton(label: submitting ? 'Enviando' : 'Enviar', onPressed: submit),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Enviar'));
    await tester.pump();

    expect(submitCount, 0);
    expect(focusNode.hasFocus, isTrue);
    expect(find.text('Informe o nome.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Maria');
    await tester.tap(find.text('Enviar'));
    await tester.pump();
    await tester.tap(find.text('Enviando'));
    await tester.pump();

    expect(submitCount, 1);

    submission.complete();
    await tester.pump();
    expect(find.text('Enviar'), findsOneWidget);

    controller.dispose();
    focusNode.dispose();
  });
}
