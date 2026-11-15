import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/models/concurso.dart';
import '../concurso_view_data.dart';
import 'edital_metrics_card.dart';

const _searchFieldWidth = 270.0;
const _summaryRailWidth = 250.0;
const _disciplineRowHeight = 68.0;
const _progressColumnWidth = 110.0;

class EditalOverview extends StatefulWidget {
  const EditalOverview({
    required this.concurso,
    required this.query,
    required this.onQueryChanged,
    required this.onEdit,
    required this.onSeeRole,
    required this.onOpenDisciplina,
    super.key,
  });

  final Concurso concurso;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onEdit;
  final VoidCallback onSeeRole;
  final ValueChanged<DisciplinaEdital> onOpenDisciplina;

  @override
  State<EditalOverview> createState() => _EditalOverviewState();
}

class _EditalOverviewState extends State<EditalOverview> {
  EditalMetricMode _metricMode = EditalMetricMode.advance;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(EditalOverview oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final normalized = widget.query.trim().toLowerCase();
    final disciplinas = widget.concurso.disciplinas
        .where((item) => normalized.isEmpty || item.nome.toLowerCase().contains(normalized))
        .toList(growable: false);
    final view = ConcursoViewData.fromDomain(widget.concurso, context.l10n);
    final metricsById = {for (final item in view.disciplines) item.id: item};
    return Padding(
      padding: EdgeInsets.only(top: context.tokens.spacing.xxl, bottom: context.tokens.spacing.jumbo),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EditalToolbar(
            role: widget.concurso.cargo,
            searchController: _searchController,
            onQueryChanged: widget.onQueryChanged,
            onEdit: widget.onEdit,
            onSeeRole: widget.onSeeRole,
          ),
          SizedBox(height: context.tokens.spacing.xxl),
          LayoutBuilder(
            builder: (context, constraints) {
              final summary = EditalMetricsCard(
                advance: widget.concurso.progressoEdital / 100,
                value: _metricMode,
                onChanged: (value) => setState(() => _metricMode = value),
              );
              final groups = _EditalDisciplineGroups(
                allDisciplinesEmpty: widget.concurso.disciplinas.isEmpty,
                disciplinas: disciplinas,
                metricsById: metricsById,
                mode: _metricMode,
                onEdit: widget.onEdit,
                onOpenDisciplina: widget.onOpenDisciplina,
              );
              if (constraints.maxWidth < context.tokens.layout.contentSplit) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    summary,
                    SizedBox(height: context.tokens.spacing.xxl),
                    groups,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: _summaryRailWidth, child: summary),
                  SizedBox(width: context.tokens.spacing.xxl),
                  Expanded(child: groups),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EditalToolbar extends StatelessWidget {
  const _EditalToolbar({
    required this.role,
    required this.searchController,
    required this.onQueryChanged,
    required this.onEdit,
    required this.onSeeRole,
  });

  final String role;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onEdit;
  final VoidCallback onSeeRole;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final heading = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(role, style: context.tokens.typography.headlineMedium),
          SizedBox(height: context.tokens.spacing.xxs),
          InkWell(
            onTap: onSeeRole,
            child: Text(
              context.l10n.viewRoleDuties,
              style: context.tokens.typography.labelLarge.copyWith(
                color: context.tokens.colors.onSurfaceMuted,
                decoration: TextDecoration.underline,
                decorationColor: context.tokens.colors.onSurfaceMuted,
              ),
            ),
          ),
        ],
      );
      final tools = Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: context.tokens.spacing.sm,
        runSpacing: context.tokens.spacing.sm,
        children: [
          SizedBox(
            width: _searchFieldWidth,
            child: AppSearchField(
              controller: searchController,
              placeholder: context.l10n.searchDiscipline,
              onChanged: onQueryChanged,
            ),
          ),
          AppButton(label: context.l10n.editSyllabus, icon: AppIcons.edit, onPressed: onEdit),
        ],
      );
      if (constraints.maxWidth < context.tokens.layout.toolbar) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            heading,
            SizedBox(height: context.tokens.spacing.lg),
            tools,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: heading),
          SizedBox(width: context.tokens.spacing.xxl),
          tools,
        ],
      );
    },
  );
}

class _EditalDisciplineGroups extends StatelessWidget {
  const _EditalDisciplineGroups({
    required this.allDisciplinesEmpty,
    required this.disciplinas,
    required this.metricsById,
    required this.mode,
    required this.onEdit,
    required this.onOpenDisciplina,
  });

  final bool allDisciplinesEmpty;
  final List<DisciplinaEdital> disciplinas;
  final Map<String, ConcursoDisciplinaProgress> metricsById;
  final EditalMetricMode mode;
  final VoidCallback onEdit;
  final ValueChanged<DisciplinaEdital> onOpenDisciplina;

  @override
  Widget build(BuildContext context) {
    if (allDisciplinesEmpty) {
      return _DisciplineGroup(
        title: context.l10n.syllabusDisciplines,
        subtitle: context.l10n.syllabusContentSubtitle,
        children: [
          Padding(
            padding: EdgeInsets.all(context.tokens.spacing.xxl),
            child: AppStateView(
              variant: AppStateVariant.empty,
              title: context.l10n.noDiscipline,
              message: context.l10n.syllabusEmptyMessage,
              actionLabel: context.l10n.editSyllabus,
              onAction: onEdit,
            ),
          ),
        ],
      );
    }
    if (disciplinas.isEmpty) {
      return _DisciplineGroup(
        title: context.l10n.syllabusDisciplines,
        subtitle: context.l10n.syllabusContentSubtitle,
        children: [
          Padding(
            padding: EdgeInsets.all(context.tokens.spacing.xl),
            child: AppStateView(
              variant: AppStateVariant.empty,
              title: context.l10n.disciplineSearchEmptyTitle,
              message: context.l10n.disciplineSearchEmptyMessage,
            ),
          ),
        ],
      );
    }

    final definitions = _MetricGroupDefinition.forMode(context, mode);
    final groups = <Widget>[];
    for (final definition in definitions) {
      final matches = disciplinas
          .where((item) {
            final metric = _metricFor(item);
            return metric != null && definition.contains(metric);
          })
          .toList(growable: false);
      if (matches.isNotEmpty) groups.add(_metricGroup(definition.title, definition.subtitle, matches));
    }
    final unavailable = disciplinas.where((item) => _metricFor(item) == null).toList(growable: false);
    if (unavailable.isNotEmpty) {
      groups.add(
        _metricGroup(
          mode == EditalMetricMode.advance ? context.l10n.advanceUnavailable : context.l10n.performanceUnavailable,
          context.l10n.metricStructureReady,
          unavailable,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < groups.length; index++) ...[
          groups[index],
          if (index < groups.length - 1) SizedBox(height: context.tokens.spacing.xl),
        ],
      ],
    );
  }

  double? _metricFor(DisciplinaEdital disciplina) {
    final metric = metricsById[disciplina.id];
    return mode == EditalMetricMode.advance ? metric?.progress : metric?.performance;
  }

  Widget _metricGroup(String title, String subtitle, List<DisciplinaEdital> items) => _DisciplineGroup(
    title: title,
    subtitle: subtitle,
    count: items.length,
    children: [
      for (var index = 0; index < items.length; index++) ...[
        _DisciplineRow(
          disciplina: items[index],
          metric: _metricFor(items[index]),
          mode: mode,
          onTap: () => onOpenDisciplina(items[index]),
        ),
        if (index < items.length - 1) const AppDivider(margin: EdgeInsets.zero),
      ],
    ],
  );
}

class _MetricGroupDefinition {
  const _MetricGroupDefinition(this.title, this.subtitle, this.minimum, this.maximum);

  final String title;
  final String subtitle;
  final double minimum;
  final double maximum;

  bool contains(double value) => value >= minimum && value <= maximum;

  static List<_MetricGroupDefinition> forMode(BuildContext context, EditalMetricMode mode) =>
      mode == EditalMetricMode.advance
      ? [
          _MetricGroupDefinition(context.l10n.advanceLowerTitle, context.l10n.advanceLowerSubtitle, 0, .25),
          _MetricGroupDefinition(context.l10n.advanceMiddleTitle, context.l10n.advanceMiddleSubtitle, .2500001, .60),
          _MetricGroupDefinition(context.l10n.advanceUpperTitle, context.l10n.advanceUpperSubtitle, .6000001, 1),
        ]
      : [
          _MetricGroupDefinition(
            context.l10n.performanceLowerTitle,
            context.l10n.performanceLowerSubtitle,
            0,
            .5999999,
          ),
          _MetricGroupDefinition(
            context.l10n.performanceMiddleTitle,
            context.l10n.performanceMiddleSubtitle,
            .60,
            .7999999,
          ),
          _MetricGroupDefinition(context.l10n.performanceUpperTitle, context.l10n.performanceUpperSubtitle, .80, 1),
        ];
}

class _DisciplineGroup extends StatelessWidget {
  const _DisciplineGroup({required this.title, required this.subtitle, required this.children, this.count});

  final String title;
  final String subtitle;
  final int? count;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.tokens.colors.surface,
      border: Border.all(color: context.tokens.colors.border),
      borderRadius: context.tokens.borders.xl,
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(context.tokens.spacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.tokens.typography.titleLarge),
                    SizedBox(height: context.tokens.spacing.xxxs),
                    Text(
                      subtitle,
                      style: context.tokens.typography.bodySmall.copyWith(color: context.tokens.colors.onSurfaceMuted),
                    ),
                  ],
                ),
              ),
              if (count case final value?) AppBadge(label: context.l10n.disciplineResults(value)),
            ],
          ),
        ),
        Divider(height: 1, color: context.tokens.colors.border),
        ...children,
      ],
    ),
  );
}

class _DisciplineRow extends StatelessWidget {
  const _DisciplineRow({required this.disciplina, required this.metric, required this.mode, required this.onTap});

  final DisciplinaEdital disciplina;
  final double? metric;
  final EditalMetricMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: context.l10n.openDiscipline(disciplina.nome),
    excludeSemantics: true,
    child: Material(
      color: context.tokens.colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _disciplineRowHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.lg),
            child: Row(
              children: [
                Expanded(child: Text(disciplina.nome, style: context.tokens.typography.labelLarge)),
                SizedBox(
                  width: _progressColumnWidth,
                  child: metric == null
                      ? Container(
                          height: context.tokens.spacing.xxs,
                          decoration: BoxDecoration(
                            color: context.tokens.colors.surfaceSubtle,
                            borderRadius: context.tokens.borders.full,
                          ),
                        )
                      : AppProgress(
                          value: metric!.clamp(0, 1),
                          variant: mode == EditalMetricMode.advance
                              ? AppProgressVariant.info
                              : AppProgressVariant.success,
                          semanticLabel: mode == EditalMetricMode.advance
                              ? context.l10n.advanceInDiscipline(disciplina.nome)
                              : context.l10n.performanceInDiscipline(disciplina.nome),
                        ),
                ),
                SizedBox(width: context.tokens.spacing.md),
                SizedBox(
                  width: context.tokens.spacing.xxxl,
                  child: Text(
                    metric == null ? '—' : '${(metric! * 100).round()}%',
                    textAlign: TextAlign.end,
                    style: context.tokens.typography.labelLarge,
                  ),
                ),
                SizedBox(width: context.tokens.spacing.md),
                AppIcon(AppIcons.chevronRight, color: context.tokens.colors.onSurfaceMuted),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
