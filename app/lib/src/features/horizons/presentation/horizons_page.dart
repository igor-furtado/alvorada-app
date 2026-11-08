import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/presentation/app_shell.dart';
import '../../../core/theme/app_theme.dart';
import 'horizon_view_data.dart';

class HorizonsPage extends StatefulWidget {
  const HorizonsPage({super.key});

  @override
  State<HorizonsPage> createState() => _HorizonsPageState();
}

class _HorizonsPageState extends State<HorizonsPage> {
  final _horizons = List<HorizonViewData>.of(demoHorizons);

  @override
  Widget build(BuildContext context) => AppShell(
    section: AppSection.horizons,
    builder: (context, desktop) {
      final callbacks = _Callbacks(
        add: _add,
        details: _details,
        edital: _edital,
        archive: _archive,
        delete: _delete,
      );
      return SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            desktop ? 40 : 20,
            20,
            desktop ? 40 : 20,
            48,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!desktop) ...[
                    const AppBrandLogo(width: 178),
                    const SizedBox(height: 28),
                  ],
                  _TimelineContent(horizons: _horizons, callbacks: callbacks),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  Future<void> _add() async {
    final result = await showDialog<_NewHorizon>(
      context: context,
      builder: (_) => const _NewHorizonDialog(),
    );
    if (result == null || !mounted) return;
    setState(() {
      _horizons.add(
        HorizonViewData(
          id: 'novo-horizonte-${DateTime.now().millisecondsSinceEpoch}',
          institution: result.institution,
          shortName: result.institution,
          role: result.role,
          board: result.board,
          examDate: 'A definir',
          days: 999,
          progress: 0,
          disciplines: const [],
        ),
      );
      _horizons.sort((a, b) => a.days.compareTo(b.days));
    });
  }

  void _details(HorizonViewData horizon) => context.go(
    '/horizontes/${Uri.encodeComponent(horizon.id)}',
    extra: horizon,
  );

  void _edital(HorizonViewData horizon) => showDialog<void>(
    context: context,
    builder: (_) => _EditalDialog(horizon: horizon),
  );

  void _archive(HorizonViewData horizon) {
    final index = _horizons.indexOf(horizon);
    setState(() => _horizons.remove(horizon));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${horizon.shortName} foi arquivado.'),
          action: SnackBarAction(
            label: 'Desfazer',
            onPressed: () => setState(() => _horizons.insert(index, horizon)),
          ),
        ),
      );
  }

  Future<void> _delete(HorizonViewData horizon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir Horizonte?'),
        content: Text(
          '${horizon.shortName} e seu Edital serão removidos. Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _horizons.remove(horizon));
    }
  }
}

typedef _HorizonAction = void Function(HorizonViewData);

class _Callbacks {
  const _Callbacks({
    required this.add,
    required this.details,
    required this.edital,
    required this.archive,
    required this.delete,
  });

  final VoidCallback add;
  final _HorizonAction details;
  final _HorizonAction edital;
  final _HorizonAction archive;
  final _HorizonAction delete;
}

class _TimelineContent extends StatelessWidget {
  const _TimelineContent({required this.horizons, required this.callbacks});
  final List<HorizonViewData> horizons;
  final _Callbacks callbacks;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 600;
      final railWidth = compact ? 64.0 : 112.0;
      final gap = compact ? 12.0 : 18.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            subtitle: 'Seus concursos-alvo em ordem de prova.',
            onAdd: callbacks.add,
          ),
          const SizedBox(height: 28),
          if (horizons.isEmpty)
            _Empty(onAdd: callbacks.add)
          else ...[
            Row(
              children: [
                SizedBox(
                  width: railWidth,
                  child: Text(
                    'HOJE',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                _Dot(),
                SizedBox(width: gap),
                Expanded(
                  child: Text(
                    'A próxima prova é em ${horizons.first.days} dias',
                  ),
                ),
              ],
            ),
            for (var i = 0; i < horizons.length; i++)
              _TimelineItem(
                horizon: horizons[i],
                last: i == horizons.length - 1,
                callbacks: callbacks,
                railWidth: railWidth,
                gap: gap,
                compact: compact,
              ),
          ],
        ],
      );
    },
  );
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.horizon,
    required this.last,
    required this.callbacks,
    required this.railWidth,
    required this.gap,
    required this.compact,
  });
  final HorizonViewData horizon;
  final bool last;
  final _Callbacks callbacks;
  final double railWidth;
  final double gap;
  final bool compact;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: railWidth,
          child: Padding(
            padding: EdgeInsets.only(top: 38, right: compact ? 8 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${horizon.days}',
                  style: compact
                      ? Theme.of(context).textTheme.titleLarge
                      : Theme.of(context).textTheme.headlineMedium,
                ),
                Text('dias', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 14,
          child: Column(
            children: [
              Expanded(child: _Line()),
              _Dot(),
              Expanded(child: last ? const SizedBox() : _Line()),
            ],
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => callbacks.details(horizon),
                child: Padding(
                  padding: EdgeInsets.all(compact ? 16 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (horizon.isPrimary) ...[
                                  const _Badge(
                                    'Horizonte principal',
                                    quiet: true,
                                  ),
                                  const SizedBox(height: 10),
                                ],
                                Text(
                                  compact
                                      ? horizon.shortName
                                      : horizon.institution,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(horizon.role),
                              ],
                            ),
                          ),
                          _Menu(horizon: horizon, callbacks: callbacks),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 32,
                        runSpacing: 10,
                        children: [
                          _LabelValue('Prova', horizon.examDate),
                          _LabelValue('Banca', horizon.board),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _Progress(horizon: horizon),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: () => callbacks.edital(horizon),
                        icon: const Icon(AppIcons.bookText, size: 18),
                        label: const Text('Abrir Edital'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Line extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 2,
      color: Theme.of(context).colorScheme.outlineVariant,
    ),
  );
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 14,
    height: 14,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      shape: BoxShape.circle,
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.subtitle, required this.onAdd});
  final String subtitle;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final heading = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Horizontes', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
      final button = FilledButton.icon(
        onPressed: onAdd,
        icon: const Icon(AppIcons.add, size: 20),
        label: const Text('Novo Horizonte'),
      );
      if (constraints.maxWidth < 620) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [heading, const SizedBox(height: 20), button],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: heading),
          const SizedBox(width: 24),
          button,
        ],
      );
    },
  );
}

class _Progress extends StatelessWidget {
  const _Progress({required this.horizon});
  final HorizonViewData horizon;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              'Avanço no Edital',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(horizon.progress * 100).round()}%',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
      const SizedBox(height: 7),
      LinearProgressIndicator(value: horizon.progress, minHeight: 7),
    ],
  );
}

class _LabelValue extends StatelessWidget {
  const _LabelValue(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(height: 3),
      Text(value),
    ],
  );
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, {this.quiet = false});
  final String label;
  final bool quiet;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: quiet
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(label, style: Theme.of(context).textTheme.labelSmall),
  );
}

enum _MenuAction { details, archive, delete }

class _Menu extends StatelessWidget {
  const _Menu({required this.horizon, required this.callbacks});
  final HorizonViewData horizon;
  final _Callbacks callbacks;

  @override
  Widget build(BuildContext context) => PopupMenuButton<_MenuAction>(
    tooltip: 'Mais ações',
    onSelected: (action) => switch (action) {
      _MenuAction.details => callbacks.details(horizon),
      _MenuAction.archive => callbacks.archive(horizon),
      _MenuAction.delete => callbacks.delete(horizon),
    },
    itemBuilder: (_) => const [
      PopupMenuItem(value: _MenuAction.details, child: Text('Ver detalhes')),
      PopupMenuItem(value: _MenuAction.archive, child: Text('Arquivar')),
      PopupMenuItem(value: _MenuAction.delete, child: Text('Excluir')),
    ],
  );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Icon(
            AppIcons.horizons,
            size: 42,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum Horizonte ativo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Adicione um concurso-alvo para começar.'),
          const SizedBox(height: 20),
          FilledButton(onPressed: onAdd, child: const Text('Novo Horizonte')),
        ],
      ),
    ),
  );
}

class _EditalDialog extends StatelessWidget {
  const _EditalDialog({required this.horizon});
  final HorizonViewData horizon;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edital'),
    content: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(horizon.shortName),
          Text(horizon.role, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          for (final discipline in horizon.disciplines) ...[
            Row(
              children: [
                Expanded(child: Text(discipline.name)),
                Text('${(discipline.progress * 100).round()}%'),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: discipline.progress, minHeight: 6),
            const SizedBox(height: 16),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Fechar'),
      ),
    ],
  );
}

class _NewHorizonDialog extends StatefulWidget {
  const _NewHorizonDialog();
  @override
  State<_NewHorizonDialog> createState() => _NewHorizonDialogState();
}

class _NewHorizonDialogState extends State<_NewHorizonDialog> {
  final institution = TextEditingController();
  final role = TextEditingController();
  final board = TextEditingController();

  @override
  void dispose() {
    institution.dispose();
    role.dispose();
    board.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Novo Horizonte'),
    content: SizedBox(
      width: 460,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: institution,
            decoration: const InputDecoration(
              labelText: 'Órgão ou instituição',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: role,
            decoration: const InputDecoration(labelText: 'Cargo'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: board,
            decoration: const InputDecoration(labelText: 'Banca'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          if (institution.text.trim().isEmpty || role.text.trim().isEmpty) {
            return;
          }
          Navigator.pop(
            context,
            _NewHorizon(
              institution: institution.text.trim(),
              role: role.text.trim(),
              board: board.text.trim().isEmpty
                  ? 'A definir'
                  : board.text.trim(),
            ),
          );
        },
        child: const Text('Adicionar'),
      ),
    ],
  );
}

class _NewHorizon {
  const _NewHorizon({
    required this.institution,
    required this.role,
    required this.board,
  });
  final String institution;
  final String role;
  final String board;
}
