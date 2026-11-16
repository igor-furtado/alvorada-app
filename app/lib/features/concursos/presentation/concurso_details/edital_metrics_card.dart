import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

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
          label: context.l10n.advance,
          content: _MetricPanel(
            value: advance,
            progressVariant: AppProgressVariant.info,
            description: context.l10n.noticeProgress,
            distribution: advanceDistribution,
            labels: [context.l10n.upTo25Percent, context.l10n.from26To60Percent, context.l10n.above60Percent],
          ),
        ),
        AppTabItem(
          value: EditalMetricMode.performance,
          label: context.l10n.performance,
          content: _MetricPanel(
            value: performance,
            progressVariant: AppProgressVariant.success,
            description: context.l10n.averagePerformance,
            distribution: performanceDistribution,
            labels: [context.l10n.below60Percent, context.l10n.from60To79Percent, context.l10n.from80Percent],
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
            style: context.tokens.typography.description,
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
            style: context.tokens.typography.description,
          ),
        ),
        Text(value?.toString() ?? '—', style: context.tokens.typography.titleMedium),
      ],
    ),
  );
}
