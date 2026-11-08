import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/app_shell.dart';
import '../../../core/theme/app_theme.dart';
import 'discipline_details_page.dart';
import 'horizon_view_data.dart';

// PROTÓTIPO DESCARTÁVEL — proposta orientada pela referência visual: resumo
// do Horizonte no topo e Edital verticalizado em uma tabela única e contínua.
class HorizonDetailsPage extends StatefulWidget {
  const HorizonDetailsPage({
    required this.horizonId,
    this.horizonOverride,
    super.key,
  });

  final String horizonId;
  final HorizonViewData? horizonOverride;

  @override
  State<HorizonDetailsPage> createState() => _HorizonDetailsPageState();
}

class _HorizonDetailsPageState extends State<HorizonDetailsPage> {
  late final HorizonViewData? _horizon =
      widget.horizonOverride ?? demoHorizonById(widget.horizonId);
  late final List<HorizonDisciplineProgress> _disciplines = List.of(
    _horizon?.disciplines ?? const [],
  );
  _DisciplineSort _sort = _DisciplineSort.weight;
  bool _sortAscending = false;

  List<HorizonDisciplineProgress> get _visibleDisciplines {
    final result = List<HorizonDisciplineProgress>.of(_disciplines);
    result.sort(
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
    final horizon = _horizon;
    return AppShell(
      section: AppSection.horizons,
      builder: (context, desktop) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            desktop ? 40 : 20,
            20,
            desktop ? 40 : 20,
            48,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1220),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!desktop) ...[
                    const AppBrandLogo(width: 178),
                    const SizedBox(height: 24),
                  ],
                  AppBreadcrumbs(
                    items: [
                      const AppBreadcrumbItem(
                        label: 'Horizontes',
                        route: '/horizontes',
                      ),
                      AppBreadcrumbItem(
                        label: horizon?.shortName ?? 'Não encontrado',
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (horizon == null)
                    const _NotFound()
                  else ...[
                    _HorizonSummary(
                      horizon: horizon,
                      disciplineCount: _disciplines.length,
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _addDiscipline,
                        icon: const Icon(AppIcons.add, size: 18),
                        label: const Text('Nova Disciplina'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _VerticalizedEdital(
                      disciplines: _visibleDisciplines,
                      sort: _sort,
                      sortAscending: _sortAscending,
                      onSort: _setSort,
                      onChangeWeight: _changeWeight,
                      onRemove: _remove,
                      onOpen: (discipline) => context.go(
                        '/horizontes/${Uri.encodeComponent(horizon.id)}/disciplinas/${Uri.encodeComponent(discipline.name)}',
                        extra: DisciplineDetailsArguments(
                          horizon: horizon,
                          discipline: discipline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
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
        HorizonDisciplineProgress(
          name: name.trim(),
          progress: 0,
          performance: 0,
          weight: 5,
        ),
      );
    });
  }

  void _changeWeight(HorizonDisciplineProgress discipline, int weight) {
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

  void _remove(HorizonDisciplineProgress discipline) {
    final index = _disciplines.indexOf(discipline);
    setState(() => _disciplines.remove(discipline));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${discipline.name} foi removida deste Edital.'),
          action: SnackBarAction(
            label: 'Desfazer',
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

typedef _DisciplineAction = void Function(HorizonDisciplineProgress);
typedef _WeightChange =
    void Function(HorizonDisciplineProgress discipline, int weight);

class _HorizonSummary extends StatelessWidget {
  const _HorizonSummary({required this.horizon, required this.disciplineCount});
  final HorizonViewData horizon;
  final int disciplineCount;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: _cardDecoration(context),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 820;
        final identity = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                AppIcons.horizonsActive,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          horizon.institution,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (horizon.isPrimary) ...[
                        const SizedBox(width: 10),
                        const _StatusBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(horizon.role),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 18,
                    runSpacing: 8,
                    children: [
                      _InlineInfo(
                        icon: Icons.event_outlined,
                        text: horizon.examDate,
                      ),
                      _InlineInfo(
                        icon: AppIcons.bookText,
                        text: '$disciplineCount disciplinas',
                      ),
                      _InlineInfo(
                        icon: Icons.account_balance_outlined,
                        text: horizon.board,
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
                value: '${(horizon.progress * 100).round()}%',
                progress: horizon.progress,
              ),
            ),
            const _VerticalDivider(),
            Expanded(
              child: _SummaryMetric(
                label: 'Desempenho',
                value: '${_averagePerformance(horizon).round()}%',
              ),
            ),
            const _VerticalDivider(),
            Expanded(
              child: _SummaryMetric(
                label: 'Prova em',
                value: '${horizon.days} dias',
              ),
            ),
          ],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [identity, const SizedBox(height: 22), metrics],
          );
        }
        return Row(
          children: [
            Expanded(flex: 6, child: identity),
            const SizedBox(width: 28),
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
  final List<HorizonDisciplineProgress> disciplines;
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
        padding: const EdgeInsets.all(48),
        decoration: _cardDecoration(context),
        child: const Center(child: Text('Nenhuma Disciplina encontrada.')),
      );
    }
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _cardDecoration(context),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 950,
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
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
        const SizedBox(width: 56, child: _HeaderLabel('Ações')),
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
  final HorizonDisciplineProgress discipline;
  final _WeightChange onChangeWeight;
  final _DisciplineAction onRemove;
  final _DisciplineAction onOpen;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () => onOpen(discipline),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      AppIcons.bookText,
                      size: 19,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
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
                width: 72,
                child: TextFormField(
                  key: ValueKey(
                    'weight-${discipline.name}-${discipline.weight}',
                  ),
                  initialValue: discipline.weight.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
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
                    width: 105,
                    child: LinearProgressIndicator(
                      value: discipline.progress,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(width: 12),
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
              width: 56,
              child: IconButton(
                tooltip: 'Remover Disciplina',
                onPressed: () => onRemove(discipline),
                icon: const Icon(Icons.delete_outline, size: 20),
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
    padding: const EdgeInsets.symmetric(horizontal: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 7),
        if (progress != null) ...[
          LinearProgressIndicator(value: progress, minHeight: 6),
          const SizedBox(height: 6),
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
    width: 1,
    height: 58,
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
        size: 17,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 6),
      Text(text, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text('Principal', style: Theme.of(context).textTheme.labelSmall),
  );
}

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel(this.label);
  final String label;
  @override
  Widget build(BuildContext context) =>
      Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall);
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
          const SizedBox(width: 4),
          Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward, size: 14),
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
    title: const Text('Nova Disciplina'),
    content: TextField(
      controller: controller,
      autofocus: true,
      decoration: const InputDecoration(labelText: 'Nome da Disciplina'),
      onSubmitted: (value) => Navigator.pop(context, value),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, controller.text),
        child: const Text('Adicionar'),
      ),
    ],
  );
}

class _NotFound extends StatelessWidget {
  const _NotFound();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 64),
    child: Center(child: Text('Horizonte não encontrado')),
  );
}

double _averagePerformance(HorizonViewData horizon) {
  if (horizon.disciplines.isEmpty) return 0;
  final total = horizon.disciplines.fold<double>(
    0,
    (sum, item) => sum + item.performance,
  );
  return total / horizon.disciplines.length * 100;
}

BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
  color: Theme.of(context).colorScheme.surface,
  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
  borderRadius: BorderRadius.circular(12),
);
