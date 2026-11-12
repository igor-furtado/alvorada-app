import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';

@immutable
class EditalMetricDistribution {
  const EditalMetricDistribution({this.lower, this.middle, this.upper});

  final int? lower;
  final int? middle;
  final int? upper;
}

class EditalMetricsCard extends StatelessWidget {
  const EditalMetricsCard({
    required this.advance,
    this.performance,
    this.value,
    this.onChanged,
    this.advanceDistribution = const EditalMetricDistribution(),
    this.performanceDistribution = const EditalMetricDistribution(),
    super.key,
  });

  final double advance;
  final double? performance;
  final EditalMetricMode? value;
  final ValueChanged<EditalMetricMode>? onChanged;
  final EditalMetricDistribution advanceDistribution;
  final EditalMetricDistribution performanceDistribution;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.all(context.tokens.spacing.sm),
    child: AppTabs<EditalMetricMode>(
      initialValue: EditalMetricMode.advance,
      value: value,
      onChanged: onChanged,
      variant: AppTabsVariant.filled,
      expanded: true,
      items: [
        AppTabItem(
          value: EditalMetricMode.advance,
          label: 'Avanço',
          content: _MetricPanel(
            value: advance,
            progressVariant: AppProgressVariant.info,
            description: 'Avanço no Edital',
            distribution: advanceDistribution,
            labels: const ['Até 25%', '26% a 60%', 'Acima de 60%'],
          ),
        ),
        AppTabItem(
          value: EditalMetricMode.performance,
          label: 'Desempenho',
          content: _MetricPanel(
            value: performance,
            progressVariant: AppProgressVariant.success,
            description: 'Desempenho médio',
            distribution: performanceDistribution,
            labels: const ['Abaixo de 60%', '60% a 79%', 'A partir de 80%'],
          ),
        ),
      ],
    ),
  );
}

enum EditalMetricMode { advance, performance }

class _MetricPanel extends StatelessWidget {
  const _MetricPanel({
    required this.value,
    required this.progressVariant,
    required this.description,
    required this.distribution,
    required this.labels,
  });

  final double? value;
  final AppProgressVariant progressVariant;
  final String description;
  final EditalMetricDistribution distribution;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final safeValue = value?.clamp(0, 1).toDouble() ?? 0;
    final values = [distribution.lower, distribution.middle, distribution.upper];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.tokens.spacing.md,
        context.tokens.spacing.xxl,
        context.tokens.spacing.md,
        context.tokens.spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            value == null ? '—' : '${(safeValue * 100).round()}%',
            style: context.tokens.typography.displayMedium,
          ),
          SizedBox(height: context.tokens.spacing.xl),
          AppProgress(
            value: safeValue,
            variant: progressVariant,
            semanticLabel: value == null ? '$description indisponível' : description,
          ),
          SizedBox(height: context.tokens.spacing.sm),
          Text(
            description,
            style: context.tokens.typography.bodyMedium.copyWith(color: context.tokens.colors.onSurfaceMuted),
          ),
          SizedBox(height: context.tokens.spacing.xl),
          const AppDivider(margin: EdgeInsets.zero),
          for (var index = 0; index < labels.length; index++) ...[
            _MetricRow(label: labels[index], value: values[index]),
            if (index < labels.length - 1) const AppDivider(margin: EdgeInsets.zero),
          ],
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: context.tokens.spacing.md),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.tokens.typography.bodyMedium.copyWith(color: context.tokens.colors.onSurfaceMuted),
          ),
        ),
        Text(value?.toString() ?? '—', style: context.tokens.typography.titleMedium),
      ],
    ),
  );
}
