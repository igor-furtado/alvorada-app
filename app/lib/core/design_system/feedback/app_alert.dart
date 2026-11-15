import 'package:material_ui/material_ui.dart';

import '../app_tokens.dart';
import '../controls/app_icon.dart';

class AppAlert extends StatelessWidget {
  const AppAlert({
    required this.title,
    required this.description,
    this.icon,
    super.key,
  });

  final String title;
  final String description;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.tokens.colors;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: context.tokens.spacing.md,
          vertical: context.tokens.spacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.card,
          border: Border.all(color: colors.border),
          borderRadius: context.tokens.borders.lg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              AppIcon(icon!, size: AppIconSize.sm, color: colors.errorForeground),
              SizedBox(width: context.tokens.spacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.tokens.typography.titleSmall.copyWith(color: colors.errorForeground),
                  ),
                  SizedBox(height: context.tokens.spacing.xxs),
                  Text(
                    description,
                    style: context.tokens.typography.bodySmall.copyWith(color: colors.errorForeground),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
