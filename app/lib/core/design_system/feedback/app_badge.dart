import 'package:material_ui/material_ui.dart';

import '../app_tokens.dart';

enum AppBadgeVariant { primary, secondary }

class AppBadge extends StatelessWidget {
  const AppBadge({required this.label, this.variant = AppBadgeVariant.primary, super.key});

  final String label;
  final AppBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    final (background, border, textStyle) = switch (variant) {
      AppBadgeVariant.primary => (
        colors.primary,
        colors.transparent,
        context.tokens.typography.compactLabelOnPrimary,
      ),
      AppBadgeVariant.secondary => (
        colors.surfaceSubtle,
        colors.transparent,
        context.tokens.typography.compactLabel,
      ),
    };
    return Semantics(
      label: label,
      child: Container(
        constraints: BoxConstraints(minHeight: context.tokens.spacing.xl),
        padding: EdgeInsets.symmetric(
          horizontal: context.tokens.spacing.sm,
          vertical: context.tokens.spacing.xxxs,
        ),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: border),
          borderRadius: context.tokens.borders.full,
        ),
        child: Text(label, style: textStyle),
      ),
    );
  }
}
