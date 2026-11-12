import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('resolve as variantes em cores semânticas', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Column(
            children: [
              AppProgress(value: .2),
              AppProgress(value: .4, variant: AppProgressVariant.info),
              AppProgress(value: .6, variant: AppProgressVariant.success),
            ],
          ),
        ),
      ),
    );

    final context = tester.element(find.byType(AppProgress).first);
    final indicators = tester.widgetList<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );

    expect(indicators.map((item) => item.color), [
      context.tokens.colors.primary,
      context.tokens.colors.info,
      context.tokens.colors.success,
    ]);
  });
}
