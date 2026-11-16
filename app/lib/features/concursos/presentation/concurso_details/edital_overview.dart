import 'dart:async';

import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/models/concurso.dart';
import '../concurso_view_data.dart';

const _summaryRailWidth = 280.0;
const _disciplineProgressWidth = 150.0;

enum _DisciplineMetric { weight, advance, performance }

class EditalOverview extends StatefulWidget {
  const EditalOverview({
    required this.concurso,
    required this.view,
    required this.query,
    required this.onQueryChanged,
    required this.onEditConcurso,
    required this.onEditEdital,
    required this.onOpenDisciplina,
    required this.onWeightChanged,
    super.key,
  });

  final Concurso concurso;
  final ConcursoViewData view;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onEditConcurso;
  final VoidCallback onEditEdital;
  final ValueChanged<DisciplinaEdital> onOpenDisciplina;
  final Future<bool> Function(DisciplinaEdital disciplina, double peso) onWeightChanged;

  @override
  State<EditalOverview> createState() => _EditalOverviewState();
}

class _EditalOverviewState extends State<EditalOverview> {
  _DisciplineMetric _metric = _DisciplineMetric.weight;
  bool _ascending = true;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant EditalOverview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query && _searchController.text != widget.query) {
      _searchController.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double? _metricFor(DisciplinaEdital disciplina, Map<String, ConcursoDisciplinaProgress> metrics) {
    final values = metrics[disciplina.id];
    return switch (_metric) {
      _DisciplineMetric.weight => disciplina.peso,
      _DisciplineMetric.advance => values?.progress,
      _DisciplineMetric.performance => values?.performance,
    };
  }

  @override
  Widget build(BuildContext context) {
    final normalized = widget.query.trim().toLowerCase();
    final metrics = {for (final item in widget.view.disciplines) item.id: item};
    final disciplines =
        widget.concurso.disciplinas
            .where((item) => normalized.isEmpty || item.nome.toLowerCase().contains(normalized))
            .toList(growable: true)
          ..sort((left, right) {
            final leftValue = _metricFor(left, metrics);
            final rightValue = _metricFor(right, metrics);
            if (leftValue == null && rightValue == null) return left.nome.compareTo(right.nome);
            if (leftValue == null) return 1;
            if (rightValue == null) return -1;
            final comparison = leftValue.compareTo(rightValue);
            return _ascending ? comparison : -comparison;
          });

    final header = _IdentityHeader(view: widget.view, onEditEdital: widget.onEditEdital);
    final toolbar = _DisciplineToolbar(
      searchController: _searchController,
      metric: _metric,
      ascending: _ascending,
      onQueryChanged: widget.onQueryChanged,
      onMetricChanged: (value) => setState(() => _metric = value),
      onSortChanged: () => setState(() => _ascending = !_ascending),
    );
    final list = _DisciplineList(
      allDisciplinesEmpty: widget.concurso.disciplinas.isEmpty,
      disciplines: disciplines,
      metrics: metrics,
      metric: _metric,
      onEditEdital: widget.onEditEdital,
      onOpenDisciplina: widget.onOpenDisciplina,
      onWeightChanged: widget.onWeightChanged,
    );
    final summaries = _SummaryRail(
      concurso: widget.concurso,
      view: widget.view,
      onEditConcurso: widget.onEditConcurso,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < context.tokens.layout.contentSplit) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              SizedBox(height: context.tokens.spacing.xl),
              summaries,
              SizedBox(height: context.tokens.spacing.xxl),
              toolbar,
              SizedBox(height: context.tokens.spacing.lg),
              list,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  SizedBox(height: context.tokens.spacing.xxl),
                  toolbar,
                  SizedBox(height: context.tokens.spacing.lg),
                  list,
                ],
              ),
            ),
            SizedBox(width: context.tokens.spacing.xxl),
            SizedBox(width: _summaryRailWidth, child: summaries),
          ],
        );
      },
    );
  }
}

class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader({required this.view, required this.onEditEdital});

  final ConcursoViewData view;
  final VoidCallback onEditEdital;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final identity = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.tokens.colors.surfaceSubtle,
              border: Border.all(color: context.tokens.colors.border),
              borderRadius: context.tokens.borders.xl,
            ),
            child: Icon(AppIcons.institution, size: context.tokens.icons.lg),
          ),
          SizedBox(width: context.tokens.spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: context.tokens.spacing.sm,
                  runSpacing: context.tokens.spacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(view.institution, style: context.tokens.typography.headlineMedium),
                    if (view.isPrimary) AppBadge(label: context.l10n.priority, variant: AppBadgeVariant.secondary),
                  ],
                ),
                SizedBox(height: context.tokens.spacing.xxs),
                Text('${view.role} · ${view.board}', style: context.tokens.typography.description),
              ],
            ),
          ),
        ],
      );
      final button = AppButton(
        key: const ValueKey('syllabus-content-button'),
        label: context.l10n.syllabusContentButton,
        icon: AppIcons.edit,
        onPressed: onEditEdital,
      );
      if (constraints.maxWidth < context.tokens.layout.toolbar) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            identity,
            SizedBox(height: context.tokens.spacing.md),
            button,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: identity),
          SizedBox(width: context.tokens.spacing.lg),
          button,
        ],
      );
    },
  );
}

class _DisciplineToolbar extends StatelessWidget {
  const _DisciplineToolbar({
    required this.searchController,
    required this.metric,
    required this.ascending,
    required this.onQueryChanged,
    required this.onMetricChanged,
    required this.onSortChanged,
  });

  final TextEditingController searchController;
  final _DisciplineMetric metric;
  final bool ascending;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<_DisciplineMetric> onMetricChanged;
  final VoidCallback onSortChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final search = AppSearchField(
        key: const ValueKey('discipline-search'),
        controller: searchController,
        placeholder: context.l10n.searchDiscipline,
        onChanged: onQueryChanged,
      );
      final sort = AppAccessibleIconButton(
        key: const ValueKey('discipline-sort'),
        icon: ascending ? AppIcons.sortAscending : AppIcons.sortDescending,
        label: ascending ? context.l10n.sortDescending : context.l10n.sortAscending,
        onPressed: onSortChanged,
      );
      final toggle = _MetricToggle(value: metric, onChanged: onMetricChanged);
      if (constraints.maxWidth < context.tokens.layout.toolbar) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            search,
            SizedBox(height: context.tokens.spacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                sort,
                SizedBox(width: context.tokens.spacing.sm),
                Flexible(child: toggle),
              ],
            ),
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: search),
          SizedBox(width: context.tokens.spacing.sm),
          sort,
          SizedBox(width: context.tokens.spacing.sm),
          toggle,
        ],
      );
    },
  );
}

class _MetricToggle extends StatelessWidget {
  const _MetricToggle({required this.value, required this.onChanged});

  final _DisciplineMetric value;
  final ValueChanged<_DisciplineMetric> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      (_DisciplineMetric.weight, context.l10n.disciplineWeight),
      (_DisciplineMetric.advance, context.l10n.advance),
      (_DisciplineMetric.performance, context.l10n.performance),
    ];
    return Container(
      key: const ValueKey('discipline-metric-toggle'),
      padding: EdgeInsets.all(context.tokens.spacing.xxs),
      decoration: BoxDecoration(
        color: context.tokens.colors.surfaceSubtle,
        borderRadius: context.tokens.borders.lg,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final children = [
            for (final item in items)
              _MetricToggleItem(
                label: item.$2,
                selected: value == item.$1,
                onTap: () => onChanged(item.$1),
              ),
          ];
          if (constraints.hasBoundedWidth && constraints.maxWidth < 330) {
            return Row(children: [for (final child in children) Expanded(child: child)]);
          }
          return Row(mainAxisSize: MainAxisSize.min, children: children);
        },
      ),
    );
  }
}

class _MetricToggleItem extends StatelessWidget {
  const _MetricToggleItem({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? context.tokens.colors.surface : context.tokens.colors.transparent,
    borderRadius: context.tokens.borders.md,
    child: InkWell(
      onTap: onTap,
      borderRadius: context.tokens.borders.md,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.sm),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: selected ? context.tokens.typography.controlLabel : context.tokens.typography.controlLabelMuted,
        ),
      ),
    ),
  );
}

class _DisciplineList extends StatelessWidget {
  const _DisciplineList({
    required this.allDisciplinesEmpty,
    required this.disciplines,
    required this.metrics,
    required this.metric,
    required this.onEditEdital,
    required this.onOpenDisciplina,
    required this.onWeightChanged,
  });

  final bool allDisciplinesEmpty;
  final List<DisciplinaEdital> disciplines;
  final Map<String, ConcursoDisciplinaProgress> metrics;
  final _DisciplineMetric metric;
  final VoidCallback onEditEdital;
  final ValueChanged<DisciplinaEdital> onOpenDisciplina;
  final Future<bool> Function(DisciplinaEdital disciplina, double peso) onWeightChanged;

  @override
  Widget build(BuildContext context) {
    if (allDisciplinesEmpty) {
      return AppStateView(
        variant: AppStateVariant.empty,
        title: context.l10n.noDiscipline,
        message: context.l10n.syllabusEmptyMessage,
        actionLabel: context.l10n.syllabusContentButton,
        onAction: onEditEdital,
      );
    }
    if (disciplines.isEmpty) {
      return AppStateView(
        variant: AppStateVariant.empty,
        title: context.l10n.disciplineSearchEmptyTitle,
        message: context.l10n.disciplineSearchEmptyMessage,
      );
    }
    return Container(
      key: const ValueKey('discipline-list-card'),
      decoration: BoxDecoration(
        color: context.tokens.colors.surface,
        border: Border.all(color: context.tokens.colors.border),
        borderRadius: context.tokens.borders.xl,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (index, discipline) in disciplines.indexed) ...[
            _DisciplineRow(
              key: ValueKey('discipline-${discipline.id}'),
              discipline: discipline,
              metrics: metrics[discipline.id],
              metric: metric,
              onTap: () => onOpenDisciplina(discipline),
              onWeightChanged: (value) => onWeightChanged(discipline, value),
            ),
            if (index < disciplines.length - 1) const AppDivider(margin: EdgeInsets.zero),
          ],
        ],
      ),
    );
  }
}

class _DisciplineRow extends StatelessWidget {
  const _DisciplineRow({
    required this.discipline,
    required this.metrics,
    required this.metric,
    required this.onTap,
    required this.onWeightChanged,
    super.key,
  });

  final DisciplinaEdital discipline;
  final ConcursoDisciplinaProgress? metrics;
  final _DisciplineMetric metric;
  final VoidCallback onTap;
  final Future<bool> Function(double peso) onWeightChanged;

  double? get _value => switch (metric) {
    _DisciplineMetric.weight => discipline.peso,
    _DisciplineMetric.advance => metrics?.progress,
    _DisciplineMetric.performance => metrics?.performance,
  };

  @override
  Widget build(BuildContext context) => Material(
    color: context.tokens.colors.transparent,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spacing.lg),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final identity = Row(
              children: [
                Container(
                  width: context.tokens.spacing.huge,
                  height: context.tokens.spacing.huge,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.tokens.colors.surfaceSubtle,
                    borderRadius: context.tokens.borders.lg,
                  ),
                  child: Icon(AppIcons.bookText, size: context.tokens.icons.md),
                ),
                SizedBox(width: context.tokens.spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(discipline.nome, style: context.tokens.typography.titleSmall),
                      SizedBox(height: context.tokens.spacing.xxs),
                      Text(
                        context.l10n.topicsInSyllabusCount(discipline.topicos.length),
                        style: context.tokens.typography.supportingText,
                      ),
                    ],
                  ),
                ),
              ],
            );
            final cluster = metric == _DisciplineMetric.weight
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _InlineWeightInput(discipline: discipline, onChanged: onWeightChanged),
                      SizedBox(width: context.tokens.spacing.md),
                      AppIcon(AppIcons.chevronRight, color: context.tokens.colors.onSurfaceMuted),
                    ],
                  )
                : _ProgressCluster(
                    disciplineName: discipline.nome,
                    value: _value,
                    performance: metric == _DisciplineMetric.performance,
                  );
            if (constraints.maxWidth < context.tokens.layout.toolbar) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  identity,
                  SizedBox(height: context.tokens.spacing.md),
                  Align(alignment: Alignment.centerRight, child: cluster),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: identity),
                SizedBox(width: context.tokens.spacing.lg),
                cluster,
              ],
            );
          },
        ),
      ),
    ),
  );
}

class _ProgressCluster extends StatelessWidget {
  const _ProgressCluster({required this.disciplineName, required this.value, required this.performance});

  final String disciplineName;
  final double? value;
  final bool performance;

  @override
  Widget build(BuildContext context) {
    final safeValue = value?.clamp(0, 1).toDouble();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _disciplineProgressWidth,
          child: safeValue == null
              ? Container(
                  height: context.tokens.spacing.xxs,
                  decoration: BoxDecoration(
                    color: context.tokens.colors.surfaceSubtle,
                    borderRadius: context.tokens.borders.full,
                  ),
                )
              : AppProgress(
                  value: safeValue,
                  variant: performance ? AppProgressVariant.success : AppProgressVariant.info,
                  semanticLabel: performance
                      ? context.l10n.performanceInDiscipline(disciplineName)
                      : context.l10n.advanceInDiscipline(disciplineName),
                ),
        ),
        SizedBox(width: context.tokens.spacing.md),
        SizedBox(
          width: 40,
          child: Text(
            safeValue == null ? '—' : '${(safeValue * 100).round()}%',
            textAlign: TextAlign.end,
            style: context.tokens.typography.controlLabel,
          ),
        ),
        SizedBox(width: context.tokens.spacing.md),
        AppIcon(AppIcons.chevronRight, color: context.tokens.colors.onSurfaceMuted),
      ],
    );
  }
}

class _InlineWeightInput extends StatefulWidget {
  const _InlineWeightInput({required this.discipline, required this.onChanged});

  final DisciplinaEdital discipline;
  final Future<bool> Function(double peso) onChanged;

  @override
  State<_InlineWeightInput> createState() => _InlineWeightInputState();
}

class _InlineWeightInputState extends State<_InlineWeightInput> {
  late final TextEditingController _controller = TextEditingController(text: _formatWeight(widget.discipline.peso));
  late final FocusNode _focusNode = FocusNode()..addListener(_handleFocusChange);
  bool _saving = false;

  @override
  void didUpdateWidget(covariant _InlineWeightInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && oldWidget.discipline.peso != widget.discipline.peso) {
      _controller.text = _formatWeight(widget.discipline.peso);
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) unawaited(_commit());
  }

  Future<void> _commit() async {
    if (_saving) return;
    final value = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    if (value == null || value <= 0 || !value.isFinite) {
      _controller.text = _formatWeight(widget.discipline.peso);
      return;
    }
    if (value == widget.discipline.peso) {
      _controller.text = _formatWeight(value);
      return;
    }
    setState(() => _saving = true);
    final saved = await widget.onChanged(value);
    if (!mounted) return;
    setState(() => _saving = false);
    _controller.text = saved ? _formatWeight(value) : _formatWeight(widget.discipline.peso);
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 76,
    child: AppTextInput(
      key: ValueKey('discipline-weight-${widget.discipline.id}'),
      controller: _controller,
      focusNode: _focusNode,
      enabled: !_saving,
      placeholder: '—',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      textAlign: TextAlign.center,
      semanticLabel: '${context.l10n.disciplineWeight}: ${widget.discipline.nome}',
      inputFormatters: [
        TextInputFormatter.withFunction((oldValue, newValue) {
          final valid = RegExp(r'^\d{0,6}([\.,]\d{0,2})?$').hasMatch(newValue.text);
          return valid ? newValue : oldValue;
        }),
      ],
      onSubmitted: (_) {
        unawaited(_commit());
        _focusNode.unfocus();
      },
    ),
  );
}

String _formatWeight(double? value) {
  if (value == null) return '';
  if (value == value.truncateToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

class _SummaryRail extends StatelessWidget {
  const _SummaryRail({required this.concurso, required this.view, required this.onEditConcurso});

  final Concurso concurso;
  final ConcursoViewData view;
  final VoidCallback onEditConcurso;

  @override
  Widget build(BuildContext context) {
    final totalTopics = concurso.disciplinas.fold<int>(0, (total, item) => total + item.topicos.length);
    final completed = (totalTopics * view.progress).round().clamp(0, totalTopics);
    final remaining = totalTopics - completed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ExamCard(view: view, onEdit: onEditConcurso),
        SizedBox(height: context.tokens.spacing.lg),
        _CoverageCard(progress: view.progress, completed: completed, remaining: remaining),
        SizedBox(height: context.tokens.spacing.lg),
        const _PerformanceCard(),
      ],
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.view, required this.onEdit});

  final ConcursoViewData view;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => AppCard(
    key: const ValueKey('exam-summary-card'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(context.l10n.exam.toUpperCase(), style: context.tokens.typography.overline)),
            AppAccessibleIconButton(
              key: const ValueKey('edit-exam-button'),
              icon: AppIcons.edit,
              label: context.l10n.editExamData,
              onPressed: onEdit,
            ),
          ],
        ),
        SizedBox(height: context.tokens.spacing.sm),
        Text(view.examDate, style: context.tokens.typography.titleLarge),
        SizedBox(height: context.tokens.spacing.xxs),
        Text(
          view.days == null ? context.l10n.toBeDefined : context.l10n.daysRemaining(view.days!),
          style: context.tokens.typography.supportingText,
        ),
        SizedBox(height: context.tokens.spacing.lg),
        const AppDivider(margin: EdgeInsets.zero),
        SizedBox(height: context.tokens.spacing.lg),
        _SummaryLine(label: context.l10n.board, value: view.board),
        _SummaryLine(label: context.l10n.location, value: view.examLocation),
        _SummaryLine(label: context.l10n.time, value: view.examTime),
      ],
    ),
  );
}

class _CoverageCard extends StatelessWidget {
  const _CoverageCard({required this.progress, required this.completed, required this.remaining});

  final double progress;
  final int completed;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0, 1).toDouble();
    return AppCard(
      key: const ValueKey('coverage-summary-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.syllabusCoverage.toUpperCase(), style: context.tokens.typography.overline),
          SizedBox(height: context.tokens.spacing.md),
          Text('${(safeProgress * 100).round()}%', style: context.tokens.typography.headlineLarge),
          SizedBox(height: context.tokens.spacing.md),
          AppProgress(value: safeProgress, variant: AppProgressVariant.info),
          SizedBox(height: context.tokens.spacing.lg),
          _SummaryLine(label: context.l10n.completed, value: '$completed'),
          _SummaryLine(label: context.l10n.remaining, value: '$remaining'),
        ],
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard();

  @override
  Widget build(BuildContext context) => AppCard(
    key: const ValueKey('performance-summary-card'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.performance.toUpperCase(), style: context.tokens.typography.overline),
        SizedBox(height: context.tokens.spacing.md),
        Text('—', style: context.tokens.typography.headlineLarge),
        SizedBox(height: context.tokens.spacing.md),
        Container(
          height: context.tokens.spacing.xxs,
          decoration: BoxDecoration(
            color: context.tokens.colors.surfaceSubtle,
            borderRadius: context.tokens.borders.full,
          ),
        ),
        SizedBox(height: context.tokens.spacing.lg),
        _SummaryLine(label: context.l10n.correctAnswers, value: '—'),
        _SummaryLine(label: context.l10n.wrongAnswers, value: '—'),
      ],
    ),
  );
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: context.tokens.spacing.xs),
    child: Row(
      children: [
        Expanded(child: Text(label, style: context.tokens.typography.description)),
        SizedBox(width: context.tokens.spacing.sm),
        Flexible(
          child: Text(value, textAlign: TextAlign.end, style: context.tokens.typography.bodyMedium),
        ),
      ],
    ),
  );
}
