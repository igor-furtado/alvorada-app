import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/content/app_messages.dart';
import '../../../core/presentation/app_shell.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_ui.dart';
import 'horizon_view_data.dart';

class HorizonsPage extends StatefulWidget {
  const HorizonsPage({super.key});

  @override
  State<HorizonsPage> createState() => _HorizonsPageState();
}

class _HorizonsPageState extends State<HorizonsPage> {
  final _horizons = List<HorizonViewData>.of(demoHorizons);

  @override
  Widget build(BuildContext context) => AppPageTemplate(
    builder: (context, desktop) {
      final callbacks = _Callbacks(
        add: _add,
        details: _details,
        edital: _edital,
        archive: _archive,
        delete: _delete,
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!desktop) ...[
            AppBrandLogo(width: context.tokens.layout.brandWidth),
            SizedBox(height: context.tokens.spacing.xxxl),
          ],
          _TimelineContent(horizons: _horizons, callbacks: callbacks),
        ],
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
      _horizons
        ..add(
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
        )
        ..sort((a, b) => a.days.compareTo(b.days));
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
    AppSnackbar.show(
      context,
      message: AppMessages.horizonArchived(horizon.shortName),
      actionLabel: AppMessages.undo,
      onAction: () => setState(() => _horizons.insert(index, horizon)),
    );
  }

  Future<void> _delete(HorizonViewData horizon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: AppMessages.deleteHorizonQuestion,
        content: Text(AppMessages.deleteHorizonImpact(horizon.shortName)),
        secondaryLabel: AppMessages.cancel,
        onSecondary: () => Navigator.pop(dialogContext, false),
        primaryLabel: AppMessages.deleteHorizon,
        onPrimary: () => Navigator.pop(dialogContext, true),
        destructive: true,
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
      final compact = constraints.maxWidth < context.tokens.layout.compact;
      final railWidth = compact
          ? context.tokens.layout.timelineRailCompact
          : context.tokens.layout.timelineRailExpanded;
      final gap = compact ? context.tokens.layout.timelineGapCompact : context.tokens.layout.timelineGapExpanded;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            subtitle: 'Seus concursos-alvo em ordem de prova.',
            onAdd: callbacks.add,
          ),
          SizedBox(height: context.tokens.spacing.xxxl),
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
            padding: EdgeInsets.only(
              top: context.tokens.spacing.page,
              right: compact ? context.tokens.spacing.sm : context.tokens.spacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${horizon.days}',
                  style: compact ? Theme.of(context).textTheme.titleLarge : Theme.of(context).textTheme.headlineMedium,
                ),
                Text(AppMessages.days, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
        SizedBox(
          width: context.tokens.spacing.lg,
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
            padding: EdgeInsets.symmetric(vertical: context.tokens.spacing.xl),
            child: Material(
              color: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                borderRadius: context.tokens.borders.lg,
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => callbacks.details(horizon),
                child: Padding(
                  padding: EdgeInsets.all(compact ? context.tokens.spacing.lg : context.tokens.spacing.xl),
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
                                  SizedBox(height: context.tokens.spacing.md),
                                ],
                                Text(
                                  compact ? horizon.shortName : horizon.institution,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                SizedBox(height: context.tokens.spacing.xxs),
                                Text(horizon.role),
                              ],
                            ),
                          ),
                          _Menu(horizon: horizon, callbacks: callbacks),
                        ],
                      ),
                      SizedBox(height: context.tokens.spacing.xl),
                      Wrap(
                        spacing: context.tokens.spacing.xxxl,
                        runSpacing: context.tokens.spacing.md,
                        children: [
                          _LabelValue('Prova', horizon.examDate),
                          _LabelValue('Banca', horizon.board),
                        ],
                      ),
                      SizedBox(height: context.tokens.spacing.xl),
                      _Progress(horizon: horizon),
                      SizedBox(height: context.tokens.spacing.md),
                      TextButton.icon(
                        onPressed: () => callbacks.edital(horizon),
                        icon: Icon(AppIcons.bookText, size: context.tokens.icons.md),
                        label: const Text(AppMessages.openNotice),
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
      width: context.tokens.sizes.progressLine,
      color: Theme.of(context).colorScheme.outlineVariant,
    ),
  );
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: context.tokens.sizes.dotLg,
    height: context.tokens.sizes.dotLg,
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
          Text(AppMessages.navigationHorizons, style: Theme.of(context).textTheme.headlineLarge),
          SizedBox(height: context.tokens.spacing.xs),
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
        icon: Icon(AppIcons.add, size: context.tokens.icons.md),
        label: const Text(AppMessages.newHorizon),
      );
      if (constraints.maxWidth < context.tokens.layout.toolbar) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            heading,
            SizedBox(height: context.tokens.spacing.xl),
            button,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: heading),
          SizedBox(width: context.tokens.spacing.xxl),
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
          SizedBox(width: context.tokens.spacing.md),
          Text(
            '${(horizon.progress * 100).round()}%',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
      SizedBox(height: context.tokens.spacing.sm),
      LinearProgressIndicator(
        value: horizon.progress,
        minHeight: context.tokens.sizes.progressIndicatorRegular,
      ),
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
      SizedBox(height: context.tokens.spacing.xxs),
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
    padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.sm, vertical: context.tokens.spacing.xxs),
    decoration: BoxDecoration(
      color: quiet
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Theme.of(context).colorScheme.primaryContainer,
      borderRadius: context.tokens.borders.sm,
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
    tooltip: AppMessages.moreActions,
    onSelected: (action) => switch (action) {
      _MenuAction.details => callbacks.details(horizon),
      _MenuAction.archive => callbacks.archive(horizon),
      _MenuAction.delete => callbacks.delete(horizon),
    },
    itemBuilder: (_) => const [
      PopupMenuItem(value: _MenuAction.details, child: Text(AppMessages.seeDetails)),
      PopupMenuItem(value: _MenuAction.archive, child: Text(AppMessages.archive)),
      PopupMenuItem(value: _MenuAction.delete, child: Text(AppMessages.delete)),
    ],
  );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: context.tokens.spacing.jumbo),
      child: Column(
        children: [
          Icon(
            AppIcons.horizons,
            size: context.tokens.icons.hero,
            color: context.tokens.colors.actionForeground,
          ),
          SizedBox(height: context.tokens.spacing.lg),
          Text(
            'Nenhum Horizonte ativo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: context.tokens.spacing.sm),
          const Text(AppMessages.emptyHorizons),
          SizedBox(height: context.tokens.spacing.xl),
          FilledButton(onPressed: onAdd, child: const Text(AppMessages.newHorizon)),
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
    title: const Text(AppMessages.notice),
    content: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: context.tokens.layout.dialogMaxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(horizon.shortName),
          Text(horizon.role, style: Theme.of(context).textTheme.bodySmall),
          SizedBox(height: context.tokens.spacing.xxl),
          for (final discipline in horizon.disciplines) ...[
            Row(
              children: [
                Expanded(child: Text(discipline.name)),
                Text('${(discipline.progress * 100).round()}%'),
              ],
            ),
            SizedBox(height: context.tokens.spacing.xs),
            LinearProgressIndicator(
              value: discipline.progress,
              minHeight: context.tokens.sizes.progressIndicatorThin,
            ),
            SizedBox(height: context.tokens.spacing.lg),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(AppMessages.close),
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
  final _formKey = GlobalKey<FormState>();
  final institution = TextEditingController();
  final role = TextEditingController();
  final board = TextEditingController();
  final institutionFocus = FocusNode();
  final roleFocus = FocusNode();

  @override
  void dispose() {
    institution.dispose();
    role.dispose();
    board.dispose();
    institutionFocus.dispose();
    roleFocus.dispose();
    super.dispose();
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? AppMessages.requiredField : null;

  FocusNode? _firstInvalidFocus() {
    if (institution.text.trim().isEmpty) return institutionFocus;
    if (role.text.trim().isEmpty) return roleFocus;
    return null;
  }

  @override
  Widget build(BuildContext context) => AppDialog(
    title: AppMessages.newHorizon,
    maxWidth: context.tokens.sizes.noteMaxWidth,
    content: AppValidatedForm(
      formKey: _formKey,
      firstInvalidFocusNode: _firstInvalidFocus,
      onSubmit: () async => Navigator.pop(
        context,
        _NewHorizon(
          institution: institution.text.trim(),
          role: role.text.trim(),
          board: board.text.trim().isEmpty ? AppMessages.toBeDefined : board.text.trim(),
        ),
      ),
      builder: (context, submitting, submit) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppFormField(
            label: AppMessages.institution,
            controller: institution,
            focusNode: institutionFocus,
            required: true,
            validator: _required,
          ),
          SizedBox(height: context.tokens.spacing.lg),
          AppFormField(
            label: AppMessages.role,
            controller: role,
            focusNode: roleFocus,
            required: true,
            validator: _required,
          ),
          SizedBox(height: context.tokens.spacing.lg),
          AppFormField(label: AppMessages.board, controller: board),
          SizedBox(height: context.tokens.spacing.xl),
          Wrap(
            spacing: context.tokens.spacing.sm,
            runSpacing: context.tokens.spacing.sm,
            alignment: WrapAlignment.end,
            children: [
              AppButton(
                label: AppMessages.cancel,
                variant: AppButtonVariant.text,
                onPressed: submitting ? null : () => Navigator.pop(context),
              ),
              AppButton(label: AppMessages.createHorizon, loading: submitting, onPressed: submit),
            ],
          ),
        ],
      ),
    ),
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
