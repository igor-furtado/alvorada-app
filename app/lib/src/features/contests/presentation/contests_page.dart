import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/content/app_messages.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_ui.dart';
import 'contest_view_data.dart';

class ContestsPage extends StatefulWidget {
  const ContestsPage({super.key});

  @override
  State<ContestsPage> createState() => _ContestsPageState();
}

class _ContestsPageState extends State<ContestsPage> {
  final _contests = List<ContestViewData>.of(demoContests);

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
          _TimelineContent(contests: _contests, callbacks: callbacks),
        ],
      );
    },
  );

  Future<void> _add() async {
    final result = await showDialog<_NewContest>(
      context: context,
      builder: (_) => const _NewContestDialog(),
    );
    if (result == null || !mounted) return;
    setState(() {
      _contests
        ..add(
          ContestViewData(
            id: 'novo-concurso-${DateTime.now().millisecondsSinceEpoch}',
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

  void _details(ContestViewData contest) => context.go(
    '/concursos/${Uri.encodeComponent(contest.id)}',
    extra: contest,
  );

  void _edital(ContestViewData contest) => showDialog<void>(
    context: context,
    builder: (_) => _EditalDialog(contest: contest),
  );

  void _archive(ContestViewData contest) {
    final index = _contests.indexOf(contest);
    setState(() => _contests.remove(contest));
    AppSnackbar.show(
      context,
      message: AppMessages.contestArchived(contest.shortName),
      actionLabel: AppMessages.undo,
      onAction: () => setState(() => _contests.insert(index, contest)),
    );
  }

  Future<void> _delete(ContestViewData contest) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: AppMessages.deleteContestQuestion,
        content: Text(AppMessages.deleteContestImpact(contest.shortName)),
        secondaryLabel: AppMessages.cancel,
        onSecondary: () => Navigator.pop(dialogContext, false),
        primaryLabel: AppMessages.deleteContest,
        onPrimary: () => Navigator.pop(dialogContext, true),
        destructive: true,
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _contests.remove(contest));
    }
  }
}

typedef _ContestAction = void Function(ContestViewData);

class _Callbacks {
  const _Callbacks({
    required this.add,
    required this.details,
    required this.edital,
    required this.archive,
    required this.delete,
  });

  final VoidCallback add;
  final _ContestAction details;
  final _ContestAction edital;
  final _ContestAction archive;
  final _ContestAction delete;
}

class _TimelineContent extends StatelessWidget {
  const _TimelineContent({required this.contests, required this.callbacks});
  final List<ContestViewData> contests;
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
            subtitle: AppMessages.contestsSubtitle,
            onAdd: callbacks.add,
          ),
          SizedBox(height: context.tokens.spacing.xxxl),
          if (contests.isEmpty)
            _Empty(onAdd: callbacks.add)
          else ...[
            Row(
              children: [
                SizedBox(
                  width: railWidth,
                  child: Text(
                    AppMessages.today.toUpperCase(),
                    style: context.tokens.typography.labelSmall,
                  ),
                ),
                const _Dot(),
                SizedBox(width: gap),
                Expanded(
                  child: Text(
                    AppMessages.nextExamIn(contests.first.days),
                    style: context.tokens.typography.bodySmall,
                  ),
                ),
              ],
            ),
            for (var index = 0; index < contests.length; index++)
              _TimelineItem(
                contest: contests[index],
                last: index == contests.length - 1,
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
    required this.contest,
    required this.last,
    required this.callbacks,
    required this.railWidth,
    required this.gap,
    required this.compact,
  });
  final ContestViewData contest;
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
                  '${contest.days}',
                  style: compact ? context.tokens.typography.titleLarge : context.tokens.typography.headlineMedium,
                ),
                Text(
                  AppMessages.days,
                  style: context.tokens.typography.bodySmall,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: context.tokens.spacing.lg,
          child: Column(
            children: [
              const Expanded(child: _Line()),
              const _Dot(),
              Expanded(child: last ? const SizedBox() : const _Line()),
            ],
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.tokens.spacing.xl,
            ),
            child: AppCard(
              onTap: () => callbacks.details(contest),
              padding: EdgeInsets.all(
                compact ? context.tokens.spacing.lg : context.tokens.spacing.xl,
              ),
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
                            if (contest.isPrimary) ...[
                              const AppBadge(
                                label: AppMessages.mainContest,
                              ),
                              SizedBox(height: context.tokens.spacing.md),
                            ],
                            Text(
                              compact ? contest.shortName : contest.institution,
                              style: context.tokens.typography.headlineSmall,
                            ),
                            SizedBox(height: context.tokens.spacing.xxs),
                            Text(contest.role),
                          ],
                        ),
                      ),
                      _Menu(contest: contest, callbacks: callbacks),
                    ],
                  ),
                  SizedBox(height: context.tokens.spacing.xl),
                  Wrap(
                    spacing: context.tokens.spacing.xxxl,
                    runSpacing: context.tokens.spacing.md,
                    children: [
                      _LabelValue(AppMessages.exam, contest.examDate),
                      _LabelValue(AppMessages.board, contest.board),
                    ],
                  ),
                  SizedBox(height: context.tokens.spacing.xl),
                  _Progress(contest: contest),
                  SizedBox(height: context.tokens.spacing.md),
                  AppButton(
                    label: AppMessages.openNotice,
                    icon: AppIcons.bookText,
                    variant: AppButtonVariant.text,
                    size: AppButtonSize.sm,
                    onPressed: () => callbacks.edital(contest),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Line extends StatelessWidget {
  const _Line();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: context.tokens.sizes.progressLine,
      color: context.tokens.colors.border,
    ),
  );
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) => Container(
    width: context.tokens.sizes.dotLg,
    height: context.tokens.sizes.dotLg,
    decoration: BoxDecoration(
      color: context.tokens.colors.primary,
      shape: BoxShape.circle,
      border: Border.all(
        color: context.tokens.colors.surface,
        width: context.tokens.borders.widthStrong,
      ),
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
          Text(AppMessages.navigationContests, style: context.tokens.typography.headlineLarge),
          SizedBox(height: context.tokens.spacing.xs),
          Text(
            subtitle,
            style: context.tokens.typography.bodyLarge.copyWith(
              color: context.tokens.colors.onSurfaceMuted,
            ),
          ),
        ],
      );
      final action = AppButton(
        label: AppMessages.newContest,
        icon: AppIcons.add,
        onPressed: onAdd,
      );
      if (constraints.maxWidth < context.tokens.layout.toolbar) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            heading,
            SizedBox(height: context.tokens.spacing.xl),
            action,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: heading),
          SizedBox(width: context.tokens.spacing.xxl),
          action,
        ],
      );
    },
  );
}

class _Progress extends StatelessWidget {
  const _Progress({required this.contest});
  final ContestViewData contest;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              AppMessages.noticeProgress,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.tokens.typography.labelMedium,
            ),
          ),
          SizedBox(width: context.tokens.spacing.md),
          Text(
            '${(contest.progress * 100).round()}%',
            style: context.tokens.typography.labelMedium,
          ),
        ],
      ),
      SizedBox(height: context.tokens.spacing.sm),
      LinearProgressIndicator(
        value: contest.progress,
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
      Text(label, style: context.tokens.typography.labelSmall),
      SizedBox(height: context.tokens.spacing.xxs),
      Text(value),
    ],
  );
}

enum _MenuAction { details, archive, delete }

class _Menu extends StatelessWidget {
  const _Menu({required this.contest, required this.callbacks});
  final ContestViewData contest;
  final _Callbacks callbacks;

  @override
  Widget build(BuildContext context) => AppMenuButton<_MenuAction>(
    icon: AppIcons.expandMore,
    label: AppMessages.moreActions,
    onSelected: (action) => switch (action) {
      _MenuAction.details => callbacks.details(contest),
      _MenuAction.archive => callbacks.archive(contest),
      _MenuAction.delete => callbacks.delete(contest),
    },
    items: const [
      AppMenuItem(
        value: _MenuAction.details,
        label: AppMessages.seeDetails,
        icon: AppIcons.arrowRight,
      ),
      AppMenuItem(
        value: _MenuAction.archive,
        label: AppMessages.archive,
      ),
      AppMenuItem(
        value: _MenuAction.delete,
        label: AppMessages.delete,
        icon: AppIcons.delete,
        destructive: true,
      ),
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
            AppIcons.contests,
            size: context.tokens.icons.hero,
            color: context.tokens.colors.actionForeground,
          ),
          SizedBox(height: context.tokens.spacing.lg),
          Text(
            AppMessages.noActiveContests,
            style: context.tokens.typography.headlineSmall,
          ),
          SizedBox(height: context.tokens.spacing.sm),
          const Text(AppMessages.emptyContests),
          SizedBox(height: context.tokens.spacing.xl),
          AppButton(
            label: AppMessages.newContest,
            icon: AppIcons.add,
            onPressed: onAdd,
          ),
        ],
      ),
    ),
  );
}

class _EditalDialog extends StatelessWidget {
  const _EditalDialog({required this.contest});
  final ContestViewData contest;

  @override
  Widget build(BuildContext context) => AppDialog(
    title: AppMessages.notice,
    content: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: context.tokens.layout.dialogMaxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(contest.shortName),
          Text(contest.role, style: context.tokens.typography.bodySmall),
          SizedBox(height: context.tokens.spacing.xxl),
          for (final discipline in contest.disciplines) ...[
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
    primaryLabel: AppMessages.close,
    onPrimary: () => Navigator.pop(context),
  );
}

class _NewContestDialog extends StatefulWidget {
  const _NewContestDialog();
  @override
  State<_NewContestDialog> createState() => _NewContestDialogState();
}

class _NewContestDialogState extends State<_NewContestDialog> {
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
  Widget build(BuildContext context) => AppValidatedForm(
    formKey: _formKey,
    firstInvalidFocusNode: _firstInvalidFocus,
    onSubmit: () async => Navigator.pop(
      context,
      _NewContest(
        institution: institution.text.trim(),
        role: role.text.trim(),
        board: board.text.trim().isEmpty ? AppMessages.toBeDefined : board.text.trim(),
      ),
    ),
    builder: (context, submitting, submit) => AppDialog(
      title: AppMessages.newContest,
      maxWidth: context.tokens.sizes.noteMaxWidth,
      content: Column(
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
        ],
      ),
      actions: [
        AppButton(
          label: AppMessages.cancel,
          variant: AppButtonVariant.outline,
          onPressed: submitting ? null : () => Navigator.pop(context),
        ),
        AppButton(
          label: AppMessages.createContest,
          loading: submitting,
          onPressed: submit,
        ),
      ],
    ),
  );
}

class _NewContest {
  const _NewContest({
    required this.institution,
    required this.role,
    required this.board,
  });
  final String institution;
  final String role;
  final String board;
}
