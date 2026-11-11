import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/content/app_messages.dart';
import '../../../core/domain/resultado.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_ui.dart';
import '../domain/models/concurso.dart';
import '../domain/use_cases/concursos_use_cases.dart';
import 'concurso_view_data.dart';

class ConcursoDetailsPage extends StatefulWidget {
  const ConcursoDetailsPage({
    required this.concursoId,
    super.key,
  });

  final String concursoId;

  @override
  State<ConcursoDetailsPage> createState() => _ConcursoDetailsPageState();
}

class _ConcursoDetailsPageState extends State<ConcursoDetailsPage> {
  ConcursoViewData? _concurso;
  bool _loading = true;
  bool _requested = false;
  _DisciplineSort _sort = _DisciplineSort.weight;
  bool _sortAscending = false;

  List<ConcursoDisciplinaProgress> get _visibleDisciplines {
    final result =
        List<ConcursoDisciplinaProgress>.of(
          _concurso?.disciplines ?? const [],
        )..sort(
          (left, right) => switch (_sort) {
            _DisciplineSort.name => right.name.compareTo(left.name),
            _DisciplineSort.weight => right.weight.compareTo(left.weight),
            _DisciplineSort.performance => right.performance.compareTo(
              left.performance,
            ),
            _DisciplineSort.progress => right.progress.compareTo(left.progress),
          },
        );
    if (_sortAscending) return result.reversed.toList();
    return result;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    _requested = true;
    unawaited(_loadConcurso());
  }

  Future<void> _loadConcurso() async {
    final result = await context.read<ConcursosUseCases>().getConcurso(
      widget.concursoId,
      forceRefresh: true,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _concurso = switch (result) {
        Sucesso<Concurso>(:final valor) => ConcursoViewData.fromDomain(valor),
        ViolacaoRegra<Concurso>() || FalhaTecnica<Concurso>() => null,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final concurso = _concurso;
    return AppPageTemplate(
      maxWidth: context.tokens.sizes.concursosPage,
      builder: (context, desktop) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBreadcrumbs(
            items: [
              const AppBreadcrumbItem(
                label: AppMessages.navigationConcursos,
                route: '/concursos',
              ),
              AppBreadcrumbItem(
                label: concurso?.shortName ?? 'Não encontrado',
              ),
            ],
          ),
          SizedBox(height: context.tokens.spacing.xl),
          if (_loading)
            AppSkeleton(
              height: context.tokens.sizes.overviewPanel,
              semanticLabel: AppMessages.carregandoConcursos,
            )
          else if (concurso == null)
            const _NotFound()
          else ...[
            _ConcursoSummary(
              concurso: concurso,
              disciplineCount: concurso.disciplines.length,
            ),
            SizedBox(height: context.tokens.spacing.xl),
            _VerticalizedEdital(
              disciplines: _visibleDisciplines,
              sort: _sort,
              sortAscending: _sortAscending,
              onSort: _setSort,
            ),
          ],
        ],
      ),
    );
  }

  void _setSort(_DisciplineSort sort) {
    setState(() {
      if (_sort == sort) {
        _sortAscending = !_sortAscending;
      } else {
        _sort = sort;
        _sortAscending = false;
      }
    });
  }
}

enum _DisciplineSort { name, weight, progress, performance }

class _ConcursoSummary extends StatelessWidget {
  const _ConcursoSummary({
    required this.concurso,
    required this.disciplineCount,
  });
  final ConcursoViewData concurso;
  final int disciplineCount;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(context.tokens.spacing.xl),
    decoration: _cardDecoration(context),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < context.tokens.layout.detail;
        final identity = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: context.tokens.sizes.iconContainerLg,
              height: context.tokens.sizes.iconContainerLg,
              decoration: BoxDecoration(
                color: context.tokens.colors.primaryContainer,
                borderRadius: context.tokens.borders.lg,
              ),
              child: Icon(
                AppIcons.concursosActive,
                color: context.tokens.colors.actionForeground,
                size: context.tokens.icons.xl,
              ),
            ),
            SizedBox(width: context.tokens.spacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          concurso.institution,
                          style: context.tokens.typography.titleLarge,
                        ),
                      ),
                      if (concurso.isPrimary) ...[
                        SizedBox(width: context.tokens.spacing.md),
                        const _StatusBadge(),
                      ],
                    ],
                  ),
                  SizedBox(height: context.tokens.spacing.xxs),
                  Text(concurso.role),
                  SizedBox(height: context.tokens.spacing.md),
                  Wrap(
                    spacing: context.tokens.spacing.xl,
                    runSpacing: context.tokens.spacing.sm,
                    children: [
                      _InlineInfo(
                        icon: AppIcons.event,
                        text: concurso.examDate,
                      ),
                      _InlineInfo(
                        icon: AppIcons.bookText,
                        text: '$disciplineCount disciplinas',
                      ),
                      _InlineInfo(
                        icon: AppIcons.institution,
                        text: concurso.board,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
        final metrics = Row(
          children: [
            Expanded(
              child: _SummaryMetric(
                label: 'Avanço no Edital',
                value: '${(concurso.progress * 100).round()}%',
                progress: concurso.progress,
              ),
            ),
            const _VerticalDivider(),
            Expanded(
              child: _SummaryMetric(
                label: 'Desempenho',
                value: '${_averagePerformance(concurso).round()}%',
              ),
            ),
            const _VerticalDivider(),
            Expanded(
              child: _SummaryMetric(
                label: 'Prova em',
                value: concurso.days == null ? AppMessages.toBeDefined : '${concurso.days} dias',
              ),
            ),
          ],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              identity,
              SizedBox(height: context.tokens.spacing.xxl),
              metrics,
            ],
          );
        }
        return Row(
          children: [
            Expanded(flex: 6, child: identity),
            SizedBox(width: context.tokens.spacing.xxxl),
            Expanded(flex: 5, child: metrics),
          ],
        );
      },
    ),
  );
}

class _VerticalizedEdital extends StatelessWidget {
  const _VerticalizedEdital({
    required this.disciplines,
    required this.sort,
    required this.sortAscending,
    required this.onSort,
  });
  final List<ConcursoDisciplinaProgress> disciplines;
  final _DisciplineSort sort;
  final bool sortAscending;
  final ValueChanged<_DisciplineSort> onSort;

  @override
  Widget build(BuildContext context) {
    if (disciplines.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(context.tokens.spacing.huge),
        decoration: _cardDecoration(context),
        child: const Center(child: Text(AppMessages.noDiscipline)),
      );
    }
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _cardDecoration(context),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: context.tokens.sizes.detailsTable,
          child: Column(
            children: [
              _TableHeader(
                sort: sort,
                sortAscending: sortAscending,
                onSort: onSort,
              ),
              for (final discipline in disciplines) _DisciplineRow(discipline: discipline),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({
    required this.sort,
    required this.sortAscending,
    required this.onSort,
  });
  final _DisciplineSort sort;
  final bool sortAscending;
  final ValueChanged<_DisciplineSort> onSort;

  @override
  Widget build(BuildContext context) => Container(
    color: context.tokens.colors.surfaceSubtle,
    padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.xl, vertical: context.tokens.spacing.lg),
    child: Row(
      children: [
        Expanded(
          flex: 36,
          child: _SortableHeader(
            label: 'Disciplina',
            selected: sort == _DisciplineSort.name,
            ascending: sortAscending,
            onTap: () => onSort(_DisciplineSort.name),
          ),
        ),
        Expanded(
          flex: 15,
          child: _SortableHeader(
            label: 'Peso no Edital',
            selected: sort == _DisciplineSort.weight,
            ascending: sortAscending,
            onTap: () => onSort(_DisciplineSort.weight),
          ),
        ),
        Expanded(
          flex: 22,
          child: _SortableHeader(
            label: 'Avanço no Edital',
            selected: sort == _DisciplineSort.progress,
            ascending: sortAscending,
            onTap: () => onSort(_DisciplineSort.progress),
          ),
        ),
        Expanded(
          flex: 18,
          child: _SortableHeader(
            label: 'Desempenho',
            selected: sort == _DisciplineSort.performance,
            ascending: sortAscending,
            onTap: () => onSort(_DisciplineSort.performance),
          ),
        ),
      ],
    ),
  );
}

class _DisciplineRow extends StatelessWidget {
  const _DisciplineRow({required this.discipline});
  final ConcursoDisciplinaProgress discipline;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.xl, vertical: context.tokens.spacing.lg),
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: context.tokens.colors.border,
        ),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 36,
          child: Row(
            children: [
              Container(
                width: context.tokens.sizes.rowIcon,
                height: context.tokens.sizes.rowIcon,
                decoration: BoxDecoration(
                  color: context.tokens.colors.primaryContainer,
                  borderRadius: context.tokens.borders.md,
                ),
                child: Icon(
                  AppIcons.bookText,
                  size: context.tokens.icons.md,
                  color: context.tokens.colors.actionForeground,
                ),
              ),
              SizedBox(width: context.tokens.spacing.lg),
              Expanded(
                child: Text(
                  discipline.name,
                  style: context.tokens.typography.titleSmall,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 15,
          child: Text(
            discipline.weight.toString(),
            textAlign: TextAlign.center,
            style: context.tokens.typography.titleSmall,
          ),
        ),
        Expanded(
          flex: 22,
          child: Row(
            children: [
              SizedBox(
                width: context.tokens.sizes.weightColumn,
                child: LinearProgressIndicator(
                  value: discipline.progress,
                  minHeight: context.tokens.sizes.progressIndicatorThin,
                ),
              ),
              SizedBox(width: context.tokens.spacing.md),
              Text(
                '${(discipline.progress * 100).round()}%',
                style: context.tokens.typography.titleSmall,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 18,
          child: Text(
            '${(discipline.performance * 100).round()}%',
            style: context.tokens.typography.titleSmall,
          ),
        ),
      ],
    ),
  );
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    this.progress,
  });
  final String label;
  final String value;
  final double? progress;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.lg),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.tokens.typography.labelSmall),
        SizedBox(height: context.tokens.spacing.sm),
        if (progress != null) ...[
          LinearProgressIndicator(
            value: progress,
            minHeight: context.tokens.sizes.progressIndicatorThin,
          ),
          SizedBox(height: context.tokens.spacing.xs),
        ],
        Text(value, style: context.tokens.typography.titleLarge),
      ],
    ),
  );
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();
  @override
  Widget build(BuildContext context) => Container(
    width: context.tokens.sizes.hairline,
    height: context.tokens.sizes.rowDividerHeight,
    color: context.tokens.colors.border,
  );
}

class _InlineInfo extends StatelessWidget {
  const _InlineInfo({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: context.tokens.icons.md,
        color: context.tokens.colors.onSurfaceMuted,
      ),
      SizedBox(width: context.tokens.spacing.xs),
      Text(text, style: context.tokens.typography.bodySmall),
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.sm, vertical: context.tokens.spacing.xxs),
    decoration: BoxDecoration(
      color: context.tokens.colors.successContainer,
      borderRadius: context.tokens.borders.full,
    ),
    child: Text(AppMessages.main, style: context.tokens.typography.labelSmall),
  );
}

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Text(label.toUpperCase(), style: context.tokens.typography.labelSmall);
}

class _SortableHeader extends StatelessWidget {
  const _SortableHeader({
    required this.label,
    required this.selected,
    required this.ascending,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final bool ascending;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Row(
      children: [
        Flexible(child: _HeaderLabel(label)),
        if (selected) ...[
          SizedBox(width: context.tokens.spacing.xxs),
          Icon(
            ascending ? AppIcons.sortAscending : AppIcons.sortDescending,
            size: context.tokens.icons.sm,
          ),
        ],
      ],
    ),
  );
}

class _NotFound extends StatelessWidget {
  const _NotFound();
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: context.tokens.spacing.giant),
    child: const Center(child: Text(AppMessages.concursoNaoEncontrado)),
  );
}

double _averagePerformance(ConcursoViewData concurso) {
  if (concurso.disciplines.isEmpty) return 0;
  final total = concurso.disciplines.fold<double>(
    0,
    (sum, item) => sum + item.performance,
  );
  return total / concurso.disciplines.length * 100;
}

BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
  color: context.tokens.colors.surface,
  border: Border.all(color: context.tokens.colors.border),
  borderRadius: context.tokens.borders.lg,
);
