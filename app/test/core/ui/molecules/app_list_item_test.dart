import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('usa as cores primárias no item selecionado em destaque', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppListItem(
            title: 'Língua Portuguesa',
            leadingIcon: AppIcons.bookText,
            variant: AppListItemVariant.primary,
            selected: true,
            onTap: () {},
          ),
        ),
      ),
    );

    final tokens = AppTheme.light.extension<AppTokens>()!;
    final surface = tester.widget<AnimatedContainer>(
      find.byKey(const ValueKey('app-list-item-surface')),
    );
    final decoration = surface.decoration! as BoxDecoration;
    final title = tester.widget<Text>(find.text('Língua Portuguesa'));

    expect(decoration.color, tokens.colors.primary);
    expect(title.style?.color, tokens.colors.onPrimary);
    final accessibleItem = find.byWidgetPredicate(
      (widget) => widget is Semantics && widget.properties.label == 'Língua Portuguesa',
    );
    expect(
      tester.getSemantics(accessibleItem),
      matchesSemantics(
        label: 'Língua Portuguesa',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        isFocusable: true,
        hasSelectedState: true,
        isSelected: true,
        hasFocusAction: true,
        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });
}
