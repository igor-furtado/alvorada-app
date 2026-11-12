import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/content/app_messages.dart';
import '../../../core/domain/resultado.dart';
import '../../../core/presentation/app_shell_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_ui.dart';
import '../domain/models/concurso.dart';
import '../domain/use_cases/concursos_use_cases.dart';
import 'concurso_details/edital_metrics_card.dart';
import 'concurso_view_data.dart';
import 'concursos_form/concursos_form_view.dart';
import 'edital_editor/edital_editor_view.dart';

class ConcursoDetailsPage extends StatefulWidget {
  const ConcursoDetailsPage({required this.concursoId, super.key});

  final String concursoId;

  @override
  State<ConcursoDetailsPage> createState() => _ConcursoDetailsPageState();
}

class _ConcursoDetailsPageState extends State<ConcursoDetailsPage> {
  AppShellController? _shellController;
  Concurso? _concurso;
  bool _loading = true;
  bool _requested = false;
  String _query = '';
  _DetailsTab _tab = _DetailsTab.edital;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shellController = AppShellScope.maybeOf(context);
    if (!identical(_shellController, shellController)) {
      _shellController?.clearBreadcrumbs(this);
      _shellController = shellController;
    }
    if (_requested) return;
    _requested = true;
    unawaited(_load());
  }

  Future<void> _load() async {
    final result = await context.read<ConcursosUseCases>().getConcurso(
      widget.concursoId,
      forceRefresh: true,
    );
    if (!mounted) return;
    final concurso = switch (result) {
      Sucesso<Concurso>(:final valor) => valor,
      ViolacaoRegra<Concurso>() || FalhaTecnica<Concurso>() => null,
    };
    setState(() {
      _loading = false;
      _concurso = concurso;
    });
    if (concurso != null) {
      _shellController?.setBreadcrumbs(this, [
        const AppShellBreadcrumb(label: AppMessages.navigationConcursos, route: '/concursos'),
        AppShellBreadcrumb(label: ConcursoViewData.fromDomain(concurso).shortName),
      ]);
    }
  }

  @override
  void dispose() {
    _shellController?.clearBreadcrumbs(this);
    super.dispose();
  }

  Future<void> _editConcurso() async {
    final concurso = _concurso;
    if (concurso == null) return;
    final saved = await showAppDrawerBuilder<bool>(
      context,
      builder: (_) => ConcursosFormView(concurso: concurso),
    );
    if (saved != true || !mounted) return;
    await _load();
    if (!mounted) return;
    AppToast.show(
      context,
      title: AppMessages.concursoAtualizado,
      variant: AppToastVariant.success,
    );
  }

  Future<void> _editEdital() async {
    final concurso = _concurso;
    if (concurso == null) return;
    await showAppDrawerBuilder<void>(
      context,
      builder: (_) => EditalEditorView(concurso: concurso),
    );
    if (mounted) await _load();
  }

  Future<void> _openDisciplina(DisciplinaEdital disciplina) => showAppDrawerBuilder<void>(
    context,
    builder: (_) => AppDrawer(
      eyebrow: 'Conteúdo do Edital',
      title: disciplina.nome,
      description: 'Tópicos desta Disciplina presentes no Edital.',
      child: AppListItemGroup(
        spacing: 0,
        children: [
          for (final topico in disciplina.topicos)
            AppListItem(
              title: topico.nome,
              leadingIcon: topico.obrigatorio ? AppIcons.lockedTopic : AppIcons.bookText,
              badge: topico.obrigatorio ? AppMessages.protected : null,
            ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return ColoredBox(
        color: context.tokens.colors.canvas,
        child: _PageContainer(
          top: context.tokens.spacing.xxl,
          child: AppSkeleton(
            height: context.tokens.sizes.overviewPanel,
            semanticLabel: AppMessages.carregandoConcursos,
          ),
        ),
      );
    }
    final concurso = _concurso;
    if (concurso == null) {
      return ColoredBox(
        color: context.tokens.colors.canvas,
        child: const _PageContainer(top: 24, child: _NotFound()),
      );
    }
    final view = ConcursoViewData.fromDomain(concurso);
    return ColoredBox(
      color: context.tokens.colors.canvas,
      child: CustomScrollView(
        key: PageStorageKey<String>('concurso-${concurso.id}'),
        slivers: [
          SliverToBoxAdapter(
            child: _Header(concurso: view, onEdit: _editConcurso),
          ),
          SliverToBoxAdapter(
            child: AppTabs<_DetailsTab>(
              initialValue: _DetailsTab.edital,
              value: _tab,
              onChanged: (value) => setState(() => _tab = value),
              variant: AppTabsVariant.line,
              headerPadding: EdgeInsets.symmetric(horizontal: _horizontalPadding(context)),
              trailing: _InlineFacts(concurso: view),
              items: [
                AppTabItem(
                  value: _DetailsTab.edital,
                  label: AppMessages.notice,
                  content: _EditalContent(
                    concurso: concurso,
                    query: _query,
                    onQueryChanged: (value) => setState(() => _query = value),
                    onEdit: _editEdital,
                    onSeeRole: () => setState(() => _tab = _DetailsTab.informacoes),
                    onOpenDisciplina: _openDisciplina,
                  ),
                ),
                AppTabItem(
                  value: _DetailsTab.informacoes,
                  label: 'Informações',
                  content: _Information(concurso: view),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _DetailsTab { edital, informacoes }

class _Header extends StatelessWidget {
  const _Header({required this.concurso, required this.onEdit});

  final ConcursoViewData concurso;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final showLocalBreadcrumbs = AppShellScope.maybeOf(context) == null;
    return ColoredBox(
      color: context.tokens.colors.surface,
      child: _PageContainer(
        top: context.tokens.spacing.xxl,
        bottom: context.tokens.spacing.xl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showLocalBreadcrumbs) ...[
              AppBreadcrumbs(
                items: [
                  const AppBreadcrumbItem(
                    label: AppMessages.navigationConcursos,
                    route: '/concursos',
                  ),
                  AppBreadcrumbItem(label: concurso.shortName),
                ],
              ),
              SizedBox(height: context.tokens.spacing.lg),
            ],
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: context.tokens.spacing.xl,
              runSpacing: context.tokens.spacing.md,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(concurso.institution, style: context.tokens.typography.headlineLarge),
                    if (concurso.organizationAcronym case final acronym?) ...[
                      SizedBox(height: context.tokens.spacing.xxs),
                      Text(
                        acronym,
                        style: context.tokens.typography.bodyMedium.copyWith(
                          color: context.tokens.colors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ],
                ),
                AppButton(
                  label: AppMessages.editarConcurso,
                  icon: AppIcons.edit,
                  variant: AppButtonVariant.outline,
                  onPressed: onEdit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineFacts extends StatelessWidget {
  const _InlineFacts({required this.concurso});

  final ConcursoViewData concurso;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (concurso.isPrimary) ...[
        const AppBadge(label: 'Prioritário', variant: AppBadgeVariant.secondary),
        SizedBox(width: context.tokens.spacing.xl),
      ],
      _InlineFact(label: 'Banca', value: concurso.board),
      _FactDot(),
      _InlineFact(label: 'Prova', value: concurso.examDate),
      _FactDot(),
      _InlineFact(label: 'Local', value: concurso.examLocation),
    ],
  );
}

class _InlineFact extends StatelessWidget {
  const _InlineFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      text: '$label  ',
      children: [
        TextSpan(
          text: value,
          style: context.tokens.typography.labelLarge.copyWith(color: context.tokens.colors.onSurface),
        ),
      ],
    ),
    maxLines: 1,
    style: context.tokens.typography.bodySmall.copyWith(color: context.tokens.colors.onSurfaceMuted),
  );
}

class _FactDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.lg),
    child: Container(
      width: context.tokens.spacing.xxxs,
      height: context.tokens.spacing.xxxs,
      decoration: BoxDecoration(
        color: context.tokens.colors.onSurfaceMuted,
        borderRadius: context.tokens.borders.full,
      ),
    ),
  );
}

class _EditalContent extends StatefulWidget {
  const _EditalContent({
    required this.concurso,
    required this.query,
    required this.onQueryChanged,
    required this.onEdit,
    required this.onSeeRole,
    required this.onOpenDisciplina,
  });

  final Concurso concurso;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onEdit;
  final VoidCallback onSeeRole;
  final ValueChanged<DisciplinaEdital> onOpenDisciplina;

  @override
  State<_EditalContent> createState() => _EditalContentState();
}

class _EditalContentState extends State<_EditalContent> {
  EditalMetricMode _metricMode = EditalMetricMode.advance;

  @override
  Widget build(BuildContext context) {
    final normalized = widget.query.trim().toLowerCase();
    final disciplinas = widget.concurso.disciplinas
        .where((item) => normalized.isEmpty || item.nome.toLowerCase().contains(normalized))
        .toList(growable: false);
    final view = ConcursoViewData.fromDomain(widget.concurso);
    final metricsById = {for (final item in view.disciplines) item.id: item};
    return _PageContainer(
      top: context.tokens.spacing.xxl,
      bottom: context.tokens.spacing.jumbo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final heading = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.concurso.cargo, style: context.tokens.typography.headlineMedium),
                  SizedBox(height: context.tokens.spacing.xxs),
                  InkWell(
                    onTap: widget.onSeeRole,
                    child: Text(
                      'Ver atribuições do cargo',
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
                    width: context.tokens.sizes.searchField,
                    child: AppSearchField(
                      placeholder: 'Buscar Disciplina',
                      onChanged: widget.onQueryChanged,
                    ),
                  ),
                  AppButton(label: 'Editar Edital', icon: AppIcons.edit, onPressed: widget.onEdit),
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
          ),
          SizedBox(height: context.tokens.spacing.xxl),
          LayoutBuilder(
            builder: (context, constraints) {
              final summary = _EditalSummary(
                concurso: widget.concurso,
                mode: _metricMode,
                onModeChanged: (value) => setState(() => _metricMode = value),
              );
              final list = Expanded(
                child: _DisciplineGroups(
                  allDisciplinesEmpty: widget.concurso.disciplinas.isEmpty,
                  disciplinas: disciplinas,
                  metricsById: metricsById,
                  mode: _metricMode,
                  onEdit: widget.onEdit,
                  onOpenDisciplina: widget.onOpenDisciplina,
                ),
              );
              if (constraints.maxWidth < context.tokens.layout.contentSplit) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    summary,
                    SizedBox(height: context.tokens.spacing.xxl),
                    _DisciplineGroups(
                      allDisciplinesEmpty: widget.concurso.disciplinas.isEmpty,
                      disciplinas: disciplinas,
                      metricsById: metricsById,
                      mode: _metricMode,
                      onEdit: widget.onEdit,
                      onOpenDisciplina: widget.onOpenDisciplina,
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: context.tokens.sizes.summaryRail, child: summary),
                  SizedBox(width: context.tokens.spacing.xxl),
                  list,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EditalSummary extends StatelessWidget {
  const _EditalSummary({
    required this.concurso,
    required this.mode,
    required this.onModeChanged,
  });

  final Concurso concurso;
  final EditalMetricMode mode;
  final ValueChanged<EditalMetricMode> onModeChanged;

  @override
  Widget build(BuildContext context) => EditalMetricsCard(
    advance: concurso.progressoEdital / 100,
    value: mode,
    onChanged: onModeChanged,
  );
}

class _DisciplineGroups extends StatelessWidget {
  const _DisciplineGroups({
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
        title: 'Disciplinas do Edital',
        subtitle: 'Conteúdo cobrado neste Concurso',
        children: [
          Padding(
            padding: EdgeInsets.all(context.tokens.spacing.xxl),
            child: AppStateView(
              variant: AppStateVariant.empty,
              title: AppMessages.noDiscipline,
              message: 'Adicione uma Disciplina ou um Tópico existente no catálogo.',
              actionLabel: 'Editar Edital',
              onAction: onEdit,
            ),
          ),
        ],
      );
    }
    if (disciplinas.isEmpty) {
      return _DisciplineGroup(
        title: 'Disciplinas do Edital',
        subtitle: 'Conteúdo cobrado neste Concurso',
        children: [
          Padding(
            padding: EdgeInsets.all(context.tokens.spacing.xl),
            child: const AppStateView(
              variant: AppStateVariant.empty,
              title: 'Nenhuma Disciplina encontrada',
              message: 'Tente buscar por outro nome.',
            ),
          ),
        ],
      );
    }

    final definitions = _MetricGroupDefinition.forMode(mode);
    final groups = <Widget>[];
    for (final definition in definitions) {
      final matches = disciplinas
          .where((disciplina) {
            final metric = _metricFor(disciplina);
            return metric != null && definition.contains(metric);
          })
          .toList(growable: false);
      if (matches.isNotEmpty) {
        groups.add(_metricGroup(definition.title, definition.subtitle, matches));
      }
    }
    final unavailable = disciplinas.where((disciplina) => _metricFor(disciplina) == null).toList(growable: false);
    if (unavailable.isNotEmpty) {
      groups.add(
        _metricGroup(
          mode == EditalMetricMode.advance ? 'Avanço ainda não calculado' : 'Desempenho ainda não calculado',
          'A estrutura está pronta para receber esta métrica',
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
  const _MetricGroupDefinition({
    required this.title,
    required this.subtitle,
    required this.minimum,
    required this.maximum,
  });

  final String title;
  final String subtitle;
  final double minimum;
  final double maximum;

  bool contains(double value) => value >= minimum && value <= maximum;

  static List<_MetricGroupDefinition> forMode(EditalMetricMode mode) => mode == EditalMetricMode.advance
      ? const [
          _MetricGroupDefinition(
            title: 'Até 25% de avanço',
            subtitle: 'Disciplinas no início do Edital',
            minimum: 0,
            maximum: .25,
          ),
          _MetricGroupDefinition(
            title: 'De 26% a 60% de avanço',
            subtitle: 'Disciplinas em desenvolvimento',
            minimum: .2500001,
            maximum: .60,
          ),
          _MetricGroupDefinition(
            title: 'Acima de 60% de avanço',
            subtitle: 'Disciplinas mais avançadas',
            minimum: .6000001,
            maximum: 1,
          ),
        ]
      : const [
          _MetricGroupDefinition(
            title: 'Abaixo de 60% de desempenho',
            subtitle: 'Disciplinas com menor aproveitamento',
            minimum: 0,
            maximum: .5999999,
          ),
          _MetricGroupDefinition(
            title: 'De 60% a 79% de desempenho',
            subtitle: 'Disciplinas com aproveitamento intermediário',
            minimum: .60,
            maximum: .7999999,
          ),
          _MetricGroupDefinition(
            title: 'A partir de 80% de desempenho',
            subtitle: 'Disciplinas com maior aproveitamento',
            minimum: .80,
            maximum: 1,
          ),
        ];
}

class _DisciplineGroup extends StatelessWidget {
  const _DisciplineGroup({
    required this.title,
    required this.subtitle,
    required this.children,
    this.count,
  });

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
                      style: context.tokens.typography.bodySmall.copyWith(
                        color: context.tokens.colors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (count case final value?) AppBadge(label: AppMessages.disciplineResults(value)),
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
  const _DisciplineRow({
    required this.disciplina,
    required this.metric,
    required this.mode,
    required this.onTap,
  });

  final DisciplinaEdital disciplina;
  final double? metric;
  final EditalMetricMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Abrir ${disciplina.nome}',
    excludeSemantics: true,
    child: Material(
      color: context.tokens.colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: context.tokens.sizes.disciplineRowHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    disciplina.nome,
                    style: context.tokens.typography.labelLarge,
                  ),
                ),
                SizedBox(
                  width: context.tokens.sizes.progressColumn,
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
                              ? 'Avanço em ${disciplina.nome}'
                              : 'Desempenho em ${disciplina.nome}',
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
                AppIcon(
                  AppIcons.chevronRight,
                  color: context.tokens.colors.onSurfaceMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _Information extends StatelessWidget {
  const _Information({required this.concurso});

  final ConcursoViewData concurso;

  @override
  Widget build(BuildContext context) => _PageContainer(
    top: context.tokens.spacing.xxxl,
    bottom: context.tokens.spacing.jumbo,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'JORNADA DO CONCURSO',
          style: context.tokens.typography.labelSmall.copyWith(color: context.tokens.colors.info),
        ),
        SizedBox(height: context.tokens.spacing.sm),
        Text('Da habilitação à posse', style: context.tokens.typography.headlineLarge),
        SizedBox(height: context.tokens.spacing.sm),
        Text(
          'As condições do Concurso apresentadas na ordem em que influenciam sua decisão.',
          style: context.tokens.typography.bodyLarge.copyWith(color: context.tokens.colors.onSurfaceMuted),
        ),
        SizedBox(height: context.tokens.spacing.xxxl),
        _JourneyStep(
          number: 1,
          stage: 'Habilitação',
          title: 'Requisito de ingresso',
          description: concurso.requirements,
        ),
        _JourneyStep(
          number: 2,
          stage: 'Avaliação',
          title: 'Provas e pontuação',
          description: concurso.scoringCriteria,
          facts: [('Horário', concurso.examTime)],
        ),
        _JourneyStep(
          number: 3,
          stage: 'Classificação',
          title: 'Oferta prevista',
          facts: [('Total', concurso.vacancies)],
        ),
        _JourneyStep(
          number: 4,
          stage: 'Posse',
          title: 'Condições do cargo',
          facts: [
            ('Vencimento inicial', concurso.remuneration),
            ('Jornada', concurso.weeklyWorkload),
          ],
          last: true,
        ),
      ],
    ),
  );
}

class _JourneyStep extends StatelessWidget {
  const _JourneyStep({
    required this.number,
    required this.stage,
    required this.title,
    this.description,
    this.facts = const [],
    this.last = false,
  });

  final int number;
  final String stage;
  final String title;
  final String? description;
  final List<(String, String)> facts;
  final bool last;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < context.tokens.layout.twoColumn;
      final marker = Container(
        width: context.tokens.sizes.stepIndicator,
        height: context.tokens.sizes.stepIndicator,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.tokens.colors.surface,
          border: Border.all(color: context.tokens.colors.controlOutline),
          borderRadius: context.tokens.borders.full,
        ),
        child: Text('$number', style: context.tokens.typography.labelSmall),
      );
      final card = AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.tokens.typography.titleMedium),
            if (description != null) ...[
              SizedBox(height: context.tokens.spacing.sm),
              Text(
                description!,
                style: context.tokens.typography.bodyMedium.copyWith(
                  color: context.tokens.colors.onSurfaceMuted,
                ),
              ),
            ],
            if (facts.isNotEmpty) ...[
              SizedBox(height: context.tokens.spacing.lg),
              Wrap(
                spacing: context.tokens.spacing.xxxl,
                runSpacing: context.tokens.spacing.lg,
                children: [
                  for (final fact in facts) _JourneyFact(label: fact.$1, value: fact.$2),
                ],
              ),
            ],
          ],
        ),
      );
      final bottom = last ? 0.0 : context.tokens.spacing.xxxl;
      if (compact) {
        return Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              marker,
              SizedBox(width: context.tokens.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(stage, style: context.tokens.typography.labelLarge),
                    SizedBox(height: context.tokens.spacing.sm),
                    card,
                  ],
                ),
              ),
            ],
          ),
        );
      }
      return Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            marker,
            SizedBox(width: context.tokens.spacing.xxl),
            SizedBox(
              width: context.tokens.sizes.compactField,
              child: Padding(
                padding: EdgeInsets.only(top: context.tokens.spacing.xs),
                child: Text(stage, style: context.tokens.typography.labelLarge),
              ),
            ),
            SizedBox(width: context.tokens.spacing.xxl),
            Expanded(child: card),
          ],
        ),
      );
    },
  );
}

class _JourneyFact extends StatelessWidget {
  const _JourneyFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: context.tokens.typography.labelSmall.copyWith(color: context.tokens.colors.onSurfaceMuted),
      ),
      SizedBox(height: context.tokens.spacing.xxxs),
      Text(value, style: context.tokens.typography.titleMedium),
    ],
  );
}

class _PageContainer extends StatelessWidget {
  const _PageContainer({required this.child, this.top = 0, this.bottom = 0});

  final Widget child;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        _horizontalPadding(context),
        top,
        _horizontalPadding(context),
        bottom,
      ),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );
}

double _horizontalPadding(BuildContext context) =>
    context.windowClass.isExpanded ? context.tokens.spacing.page : context.tokens.spacing.xl;

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) => const AppStateView(
    variant: AppStateVariant.empty,
    title: AppMessages.concursoNaoEncontrado,
    message: 'Volte para Concursos e escolha outro item.',
  );
}
