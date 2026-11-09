import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/content/app_messages.dart';
import '../../../core/presentation/app_shell.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_ui.dart';
import 'contest_view_data.dart';
import 'discipline_details_page.dart';

// PROTÓTIPO DESCARTÁVEL — proposta orientada pela referência visual: resumo
// do Concurso no topo e Edital verticalizado em uma tabela única e contínua.
class ContestDetailsPage extends StatefulWidget {
  const ContestDetailsPage({
    required this.contestId,
    this.contestOverride,
    super.key,
  });

  final String contestId;
  final ContestViewData? contestOverride;

  @override
  State<ContestDetailsPage> createState() => _ContestDetailsPageState();
}

class _ContestDetailsPageState extends State<ContestDetailsPage> {
  late final ContestViewData? _contest = widget.contestOverride ?? demoContestById(widget.contestId);
  late final List<ContestDisciplineProgress> _disciplines = List.of(
    _contest?.disciplines ?? const [],
  );
  _DisciplineSort _sort = _DisciplineSort.weight;
  bool _sortAscending = false;

  List<ContestDisciplineProgress> get _visibleDisciplines {
    final result = List<ContestDisciplineProgress>.of(_disciplines)
      ..sort(
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
  Widget build(BuildContext context) {
    final contest = _contest;
    return AppPageTemplate(
      maxWidth: context.tokens.sizes.contestPage,
      builder: (context, desktop) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!desktop) ...[
            AppBrandLogo(width: context.tokens.layout.brandWidth),
            SizedBox(height: context.tokens.spacing.xxl),
          ],
          AppBreadcrumbs(
            items: [
              const AppBreadcrumbItem(
                label: AppMessages.navigationContests,
                route: '/concursos',
              ),
              AppBreadcrumbItem(
                label: contest?.shortName ?? 'Não encontrado',
              ),
            ],
          ),
          SizedBox(height: context.tokens.spacing.xl),
          if (contest == null)
            const _NotFound()
          else ...[
            _ContestSummary(
              contest: contest,
              disciplineCount: _disciplines.length,
            ),
            SizedBox(height: context.tokens.spacing.xl),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _addDiscipline,
                icon: Icon(AppIcons.add, size: context.tokens.icons.md),
                label: const Text(AppMessages.newDiscipline),
              ),
            ),
            SizedBox(height: context.tokens.spacing.lg),
            _VerticalizedEdital(
              disciplines: _visibleDisciplines,
              sort: _sort,
              sortAscending: _sortAscending,
              onSort: _setSort,
              onChangeWeight: _changeWeight,
              onRemove: _remove,
              onOpen: (discipline) => context.go(
                '/concursos/${Uri.encodeComponent(contest.id)}/disciplinas/${Uri.encodeComponent(discipline.name)}',
                extra: DisciplineDetailsArguments(
                  contest: contest,
                  discipline: discipline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addDiscipline() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _AddDisciplineDialog(),
    );
    if (name == null || name.trim().isEmpty || !mounted) return;
    setState(() {
      _disciplines.add(
        ContestDisciplineProgress(
          name: name.trim(),
          progress: 0,
          performance: 0,
          weight: 5,
        ),
      );
    });
  }

  void _changeWeight(ContestDisciplineProgress discipline, int weight) {
    final index = _disciplines.indexOf(discipline);
    if (index < 0) return;
    setState(() => _disciplines[index] = discipline.copyWith(weight: weight));
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

  void _remove(ContestDisciplineProgress discipline) {
    final index = _disciplines.indexOf(discipline);
    setState(() => _disciplines.remove(discipline));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(AppMessages.disciplineRemoved(discipline.name)),
          action: SnackBarAction(
            label: AppMessages.undo,
            onPressed: () => setState(
              () => _disciplines.insert(
                index.clamp(0, _disciplines.length),
                discipline,
              ),
            ),
          ),
        ),
      );
  }
}

enum _DisciplineSort { name, weight, progress, performance }

typedef _DisciplineAction = void Function(ContestDisciplineProgress);
typedef _WeightChange = void Function(ContestDisciplineProgress discipline, int weight);

class _ContestSummary extends StatelessWidget {
  const _ContestSummary({required this.contest, required this.disciplineCount});
  final ContestViewData contest;
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
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: context.tokens.borders.lg,
              ),
              child: Icon(
                AppIcons.contestsActive,
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
                          contest.institution,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (contest.isPrimary) ...[
                        SizedBox(width: context.tokens.spacing.md),
                        const _StatusBadge(),
                      ],
                    ],
                  ),
                  SizedBox(height: context.tokens.spacing.xxs),
                  Text(contest.role),
                  SizedBox(height: context.tokens.spacing.md),
                  Wrap(
                    spacing: context.tokens.spacing.xl,
                    runSpacing: context.tokens.spacing.sm,
                    children: [
                      _InlineInfo(
                        icon: AppIcons.event,
                        text: contest.examDate,
                      ),
                      _InlineInfo(
                        icon: AppIcons.bookText,
                        text: '$disciplineCount disciplinas',
                      ),
                      _InlineInfo(
                        icon: AppIcons.institution,
                        text: contest.board,
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
                value: '${(contest.progress * 100).round()}%',
                progress: contest.progress,
              ),
            ),
            const _VerticalDivider(),
            Expanded(
              child: _SummaryMetric(
                label: 'Desempenho',
                value: '${_averagePerformance(contest).round()}%',
              ),
            ),
            const _VerticalDivider(),
            Expanded(
              child: _SummaryMetric(
                label: 'Prova em',
                value: '${contest.days} dias',
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
    required this.onChangeWeight,
    required this.onRemove,
    required this.onOpen,
  });
  final List<ContestDisciplineProgress> disciplines;
  final _DisciplineSort sort;
  final bool sortAscending;
  final ValueChanged<_DisciplineSort> onSort;
  final _WeightChange onChangeWeight;
  final _DisciplineAction onRemove;
  final _DisciplineAction onOpen;

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
              for (final discipline in disciplines)
                _DisciplineRow(
                  discipline: discipline,
                  onChangeWeight: onChangeWeight,
                  onRemove: onRemove,
                  onOpen: onOpen,
                ),
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
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
        SizedBox(
          width: context.tokens.layout.tableActionsColumn,
          child: const _HeaderLabel('Ações'),
        ),
      ],
    ),
  );
}

class _DisciplineRow extends StatelessWidget {
  const _DisciplineRow({
    required this.discipline,
    required this.onChangeWeight,
    required this.onRemove,
    required this.onOpen,
  });
  final ContestDisciplineProgress discipline;
  final _WeightChange onChangeWeight;
  final _DisciplineAction onRemove;
  final _DisciplineAction onOpen;

  @override
  Widget build(BuildContext context) => Material(
    color: context.tokens.colors.transparent,
    child: InkWell(
      onTap: () => onOpen(discipline),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.xl, vertical: context.tokens.spacing.lg),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
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
                      color: Theme.of(context).colorScheme.primaryContainer,
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
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 15,
              child: SizedBox(
                width: context.tokens.sizes.largeVisual,
                child: TextFormField(
                  key: ValueKey(
                    'weight-${discipline.name}-${discipline.weight}',
                  ),
                  initialValue: discipline.weight.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: context.tokens.spacing.md,
                      vertical: context.tokens.spacing.md,
                    ),
                  ),
                  onFieldSubmitted: (value) {
                    final weight = int.tryParse(value);
                    if (weight != null) onChangeWeight(discipline, weight);
                  },
                ),
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
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 18,
              child: Text(
                '${(discipline.performance * 100).round()}%',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            SizedBox(
              width: context.tokens.layout.tableActionsColumn,
              child: IconButton(
                tooltip: AppMessages.removeDiscipline,
                onPressed: () => onRemove(discipline),
                icon: Icon(AppIcons.delete, size: context.tokens.icons.md),
              ),
            ),
          ],
        ),
      ),
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
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        SizedBox(height: context.tokens.spacing.sm),
        if (progress != null) ...[
          LinearProgressIndicator(
            value: progress,
            minHeight: context.tokens.sizes.progressIndicatorThin,
          ),
          SizedBox(height: context.tokens.spacing.xs),
        ],
        Text(value, style: Theme.of(context).textTheme.titleLarge),
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
    color: Theme.of(context).colorScheme.outlineVariant,
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
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      SizedBox(width: context.tokens.spacing.xs),
      Text(text, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.sm, vertical: context.tokens.spacing.xxs),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: context.tokens.borders.full,
    ),
    child: Text(AppMessages.main, style: Theme.of(context).textTheme.labelSmall),
  );
}

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall);
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

class _AddDisciplineDialog extends StatefulWidget {
  const _AddDisciplineDialog();
  @override
  State<_AddDisciplineDialog> createState() => _AddDisciplineDialogState();
}

class _AddDisciplineDialogState extends State<_AddDisciplineDialog> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(AppMessages.newDiscipline),
    content: TextField(
      controller: controller,
      autofocus: true,
      decoration: const InputDecoration(labelText: AppMessages.disciplineName),
      onSubmitted: (value) => Navigator.pop(context, value),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(AppMessages.cancel),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, controller.text),
        child: const Text(AppMessages.add),
      ),
    ],
  );
}

class _NotFound extends StatelessWidget {
  const _NotFound();
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: context.tokens.spacing.giant),
    child: const Center(child: Text(AppMessages.contestNotFound)),
  );
}

double _averagePerformance(ContestViewData contest) {
  if (contest.disciplines.isEmpty) return 0;
  final total = contest.disciplines.fold<double>(
    0,
    (sum, item) => sum + item.performance,
  );
  return total / contest.disciplines.length * 100;
}

BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
  color: Theme.of(context).colorScheme.surface,
  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
  borderRadius: context.tokens.borders.lg,
);
