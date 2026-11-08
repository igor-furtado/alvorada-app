import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../molecules/app_metric_item.dart';

enum AppMetricTone { primary, error, success, info }

class AppMetricOverview extends StatelessWidget {
  const AppMetricOverview({required this.items, this.tone = AppMetricTone.primary, super.key});

  final List<AppMetricData> items;
  final AppMetricTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.tokens.colors;
    final (background, foreground) = switch (tone) {
      AppMetricTone.primary => (scheme.primaryContainer, scheme.primary),
      AppMetricTone.error => (
        scheme.error.withValues(alpha: context.tokens.opacity.tintStrong),
        scheme.onSurface,
      ),
      AppMetricTone.success => (colors.successContainer, colors.success),
      AppMetricTone.info => (colors.infoContainer, colors.info),
    };
    return Container(
      padding: EdgeInsets.all(context.tokens.spacing.xl),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: context.tokens.borders.lg,
      ),
      child: Wrap(
        spacing: context.tokens.spacing.xxxl,
        runSpacing: context.tokens.spacing.lg,
        children: [
          for (final item in items) AppMetricItem(data: item, backgroundColor: background, foregroundColor: foreground),
        ],
      ),
    );
  }
}
