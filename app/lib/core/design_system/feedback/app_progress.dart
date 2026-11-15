import 'package:material_ui/material_ui.dart';

import '../app_tokens.dart';
import '../design_system_localizations.dart';

enum AppProgressVariant { primary, info, success }

class AppProgress extends StatelessWidget {
  const AppProgress({
    required this.value,
    this.semanticLabel,
    this.variant = AppProgressVariant.primary,
    super.key,
  }) : assert(value >= 0 && value <= 1, 'Progress must be between 0 and 1.');

  final double value;
  final String? semanticLabel;
  final AppProgressVariant variant;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel ?? context.l10n.progress,
    value: '${(value * 100).round()}%',
    child: ClipRRect(
      borderRadius: context.tokens.borders.full,
      child: SizedBox(
        height: context.tokens.spacing.xxs,
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: context.tokens.colors.surfaceSubtle,
          color: switch (variant) {
            AppProgressVariant.primary => context.tokens.colors.primary,
            AppProgressVariant.info => context.tokens.colors.info,
            AppProgressVariant.success => context.tokens.colors.success,
          },
        ),
      ),
    ),
  );
}
