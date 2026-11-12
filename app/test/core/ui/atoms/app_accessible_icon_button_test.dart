import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('aplica destaque primário sem perder o nome acessível', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppAccessibleIconButton(
            icon: AppIcons.add,
            label: 'Adicionar Tópico',
            variant: AppIconButtonVariant.primary,
            onPressed: () {},
          ),
        ),
      ),
    );

    final tokens = AppTheme.light.extension<AppTokens>()!;
    final button = tester.widget<IconButton>(find.byType(IconButton));

    expect(button.style?.backgroundColor?.resolve({}), tokens.colors.primary);
    expect(button.style?.foregroundColor?.resolve({}), tokens.colors.onPrimary);
    final accessibleButton = find.bySemanticsLabel('Adicionar Tópico');
    expect(accessibleButton, findsOneWidget);
    expect(
      tester.getSemantics(accessibleButton),
      matchesSemantics(
        label: 'Adicionar Tópico',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });
}
