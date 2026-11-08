import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/content/app_messages.dart';
import '../../../core/presentation/app_shell.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_ui.dart';

class WeekPage extends StatelessWidget {
  const WeekPage({super.key});

  static const _days = [
    _DayPlan(
      weekday: 'Segunda',
      date: '2 nov.',
      duration: '2 h',
      status: _DayStatus.done,
      entries: [
        _TurnPreview(
          icon: AppIcons.bookText,
          title: 'Direito Constitucional',
          detail: 'Leitura corrida · Controle de constitucionalidade',
          duration: '50 min',
        ),
        _TurnPreview(
          icon: AppIcons.fromMemory,
          title: 'De cabeça',
          detail: 'Cinco linhas com o material fechado',
          duration: '10 min',
        ),
        _TurnPreview(
          icon: AppIcons.questions,
          title: 'Língua Portuguesa',
          detail: 'Questões de interpretação de texto',
          duration: '50 min',
        ),
        _TurnPreview(
          icon: AppIcons.errorNotebook,
          title: 'Caderno de Erros',
          detail: 'Motivos registrados',
          duration: '10 min',
        ),
      ],
    ),
    _DayPlan(
      weekday: 'Terça',
      date: '3 nov.',
      duration: '2 h',
      status: _DayStatus.done,
      entries: [
        _TurnPreview(
          icon: AppIcons.bookText,
          title: 'Direito Constitucional',
          detail: 'Leitura corrida · Poder constituinte',
          duration: '50 min',
        ),
        _TurnPreview(
          icon: AppIcons.fromMemory,
          title: 'De cabeça',
          detail: 'Cinco linhas com o material fechado',
          duration: '10 min',
        ),
        _TurnPreview(
          icon: AppIcons.questions,
          title: 'Direito Administrativo',
          detail: 'Questões · Atos administrativos',
          duration: '50 min',
        ),
        _TurnPreview(
          icon: AppIcons.errorNotebook,
          title: 'Caderno de Erros',
          detail: 'Motivos registrados',
          duration: '10 min',
        ),
      ],
    ),
    _DayPlan(
      weekday: 'Quarta',
      date: '4 nov.',
      duration: '2 h',
      status: _DayStatus.done,
      entries: [
        _TurnPreview(
          icon: AppIcons.bookText,
          title: 'Direito Constitucional',
          detail: 'Leitura corrida · Direitos fundamentais',
          duration: '50 min',
        ),
        _TurnPreview(
          icon: AppIcons.fromMemory,
          title: 'De cabeça',
          detail: 'Cinco linhas com o material fechado',
          duration: '10 min',
        ),
        _TurnPreview(
          icon: AppIcons.questions,
          title: 'Língua Portuguesa',
          detail: 'Questões · Sintaxe',
          duration: '50 min',
        ),
        _TurnPreview(
          icon: AppIcons.errorNotebook,
          title: 'Caderno de Erros',
          detail: 'Motivos registrados',
          duration: '10 min',
        ),
      ],
    ),
    _DayPlan(
      weekday: 'Quinta',
      date: '5 nov.',
      duration: '2 h',
      status: _DayStatus.done,
      entries: [
        _TurnPreview(
          icon: AppIcons.bookText,
          title: 'Direito Constitucional',
          detail: 'Leitura corrida · Organização do Estado',
          duration: '50 min',
        ),
        _TurnPreview(
          icon: AppIcons.fromMemory,
          title: 'De cabeça',
          detail: 'Cinco linhas com o material fechado',
          duration: '10 min',
        ),
        _TurnPreview(
          icon: AppIcons.questions,
          title: 'Direito Administrativo',
          detail: 'Questões · Poderes administrativos',
          duration: '50 min',
        ),
        _TurnPreview(
          icon: AppIcons.errorNotebook,
          title: 'Caderno de Erros',
          detail: 'Motivos registrados',
          duration: '10 min',
        ),
      ],
    ),
    _DayPlan(
      weekday: 'Sexta',
      date: '6 nov.',
      duration: '2 h',
      status: _DayStatus.today,
      entries: [
        _TurnPreview(
          icon: AppIcons.reviews,
          title: 'Revisões de 7 dias',
          detail: 'Caixas + De cabeça · 4 Tópicos',
          duration: '60 min',
        ),
        _TurnPreview(
          icon: AppIcons.questions,
          title: 'Questões mistas',
          detail: 'Disciplinas de encaixe',
          duration: '50 min',
        ),
        _TurnPreview(
          icon: AppIcons.errorNotebook,
          title: 'Caderno de Erros',
          detail: 'Corrigir e registrar os motivos',
          duration: '10 min',
        ),
      ],
    ),
    _DayPlan(
      weekday: 'Sábado',
      date: '7 nov.',
      duration: '4 h',
      status: _DayStatus.planned,
      entries: [
        _TurnPreview(
          icon: AppIcons.bookText,
          title: 'Bloco principal',
          detail: 'Direito Constitucional',
          duration: '2 h',
        ),
        _TurnPreview(
          icon: AppIcons.reviews,
          title: 'Revisões de 30 dias',
          detail: 'Questões dos Tópicos de outubro',
          duration: '1 h',
        ),
        _TurnPreview(
          icon: AppIcons.mockExam,
          title: 'Questões cronometradas',
          detail: 'Bloco fechado, sem interrupção',
          duration: '1 h',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) => AppPageTemplate(
    builder: (context, desktop) => _WeekContent(days: _days, desktop: desktop),
  );
}

class _WeekContent extends StatelessWidget {
  const _WeekContent({required this.days, required this.desktop});

  final List<_DayPlan> days;
  final bool desktop;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (!desktop) ...[
        AppBrandLogo(width: context.tokens.layout.brandWidth),
        SizedBox(height: context.tokens.spacing.xxxl),
      ],
      const _WeekHeader(),
      SizedBox(height: context.tokens.spacing.xxxl),
      const _WeekSummary(),
      SizedBox(height: context.tokens.spacing.xxxl),
      const _DaysHeader(),
      SizedBox(height: context.tokens.spacing.lg),
      LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= context.tokens.layout.threeColumn
              ? 3
              : constraints.maxWidth >= context.tokens.layout.twoColumn
              ? 2
              : 1;
          final gaps = context.tokens.spacing.lg * (columns - 1);
          final width = (constraints.maxWidth - gaps) / columns;
          return Wrap(
            spacing: context.tokens.spacing.lg,
            runSpacing: context.tokens.spacing.lg,
            children: [
              for (final day in days)
                SizedBox(
                  width: width,
                  child: _StudyDayCard(
                    day: day,
                    keepMinimumHeight: columns > 1,
                  ),
                ),
            ],
          );
        },
      ),
      SizedBox(height: context.tokens.spacing.lg),
      const _SundayCard(),
      SizedBox(height: context.tokens.spacing.xxl),
      const _ReplanningNote(),
    ],
  );
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < context.tokens.layout.twoColumn;
      final title = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppMessages.thisWeek, style: Theme.of(context).textTheme.headlineLarge),
          SizedBox(height: context.tokens.spacing.xs),
          Text(
            '2 a 8 de novembro · Consolidação',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
      final controls = Row(
        mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
        children: [
          IconButton.outlined(
            tooltip: AppMessages.previousWeek,
            onPressed: () => _showPreviewMessage(context),
            icon: const Icon(AppIcons.chevronLeft),
          ),
          SizedBox(width: context.tokens.spacing.sm),
          IconButton.outlined(
            tooltip: AppMessages.nextWeek,
            onPressed: () => _showPreviewMessage(context),
            icon: const Icon(AppIcons.chevronRight),
          ),
          SizedBox(width: context.tokens.spacing.md),
          Expanded(
            flex: compact ? 1 : 0,
            child: FilledButton.icon(
              onPressed: () => _showAdjustmentDialog(context),
              icon: Icon(AppIcons.settings, size: context.tokens.icons.md),
              label: const Text(AppMessages.adjustWeek),
            ),
          ),
        ],
      );

      if (compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            title,
            SizedBox(height: context.tokens.spacing.xl),
            controls,
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: title),
          controls,
        ],
      );
    },
  );
}

class _WeekSummary extends StatelessWidget {
  const _WeekSummary();

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(context.tokens.spacing.xl),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: context.tokens.borders.lg,
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '8 de 14 horas realizadas',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: context.tokens.spacing.xxs),
                  Text(
                    'A semana segue no ritmo planejado.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Text('57%', style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
        SizedBox(height: context.tokens.spacing.md),
        LinearProgressIndicator(
          value: 8 / 14,
          minHeight: context.tokens.sizes.progressIndicatorRegular,
        ),
        SizedBox(height: context.tokens.spacing.xl),
        Wrap(
          spacing: context.tokens.spacing.xxxl,
          runSpacing: context.tokens.spacing.lg,
          children: const [
            _SummaryItem(
              icon: AppIcons.horizons,
              label: 'Horizonte principal',
              value: 'Analista Legislativo',
            ),
            _SummaryItem(
              icon: AppIcons.bookText,
              label: 'Disciplina principal',
              value: 'Direito Constitucional',
            ),
            _SummaryItem(
              icon: AppIcons.questions,
              label: 'Disciplina de encaixe',
              value: 'Língua Portuguesa',
            ),
            _SummaryItem(
              icon: AppIcons.reviews,
              label: 'Revisões programadas',
              value: '7 nesta semana',
            ),
          ],
        ),
      ],
    ),
  );
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: context.tokens.sizes.weekSummary,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: context.tokens.icons.md, color: context.tokens.colors.actionForeground),
        SizedBox(width: context.tokens.spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              SizedBox(height: context.tokens.spacing.xxs),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _LegendDot(color: Theme.of(context).colorScheme.secondary),
      SizedBox(width: context.tokens.spacing.xs),
      Text(AppMessages.done, style: Theme.of(context).textTheme.labelSmall),
      SizedBox(width: context.tokens.spacing.md),
      _LegendDot(color: Theme.of(context).colorScheme.primary),
      SizedBox(width: context.tokens.spacing.xs),
      Text(AppMessages.today, style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}

class _DaysHeader extends StatelessWidget {
  const _DaysHeader();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final title = Text(
        'Dias da semana',
        style: Theme.of(context).textTheme.headlineSmall,
      );
      if (constraints.maxWidth < context.tokens.layout.narrow) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title,
            SizedBox(height: context.tokens.spacing.md),
            const _Legend(),
          ],
        );
      }
      return Row(children: [title, const Spacer(), const _Legend()]);
    },
  );
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: context.tokens.sizes.dotSm,
    height: context.tokens.sizes.dotSm,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _StudyDayCard extends StatelessWidget {
  const _StudyDayCard({required this.day, required this.keepMinimumHeight});

  final _DayPlan day;
  final bool keepMinimumHeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final current = day.status == _DayStatus.today;
    final done = day.status == _DayStatus.done;
    final accent = current
        ? scheme.primary
        : done
        ? scheme.secondary
        : scheme.outline;

    return Container(
      constraints: BoxConstraints(minHeight: keepMinimumHeight ? 350 : 0),
      padding: EdgeInsets.all(context.tokens.spacing.xl),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(
          color: current ? scheme.primary : scheme.outlineVariant,
        ),
        borderRadius: context.tokens.borders.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: context.tokens.sizes.dotMd,
                height: context.tokens.sizes.dotMd,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: context.tokens.spacing.sm),
              Expanded(
                child: Text(
                  day.weekday,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                day.duration,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          SizedBox(height: context.tokens.spacing.xxs),
          Padding(
            padding: EdgeInsets.only(left: context.tokens.spacing.xl),
            child: Text(day.date, style: Theme.of(context).textTheme.bodySmall),
          ),
          SizedBox(height: context.tokens.spacing.lg),
          Divider(color: scheme.outlineVariant),
          SizedBox(height: context.tokens.spacing.xxs),
          for (var index = 0; index < day.entries.length; index++) ...[
            _TurnRow(turn: day.entries[index], done: done),
            if (index < day.entries.length - 1)
              Divider(height: context.tokens.spacing.lg, color: scheme.outlineVariant),
          ],
          if (current) ...[
            SizedBox(height: context.tokens.spacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.go('/'),
                icon: Icon(AppIcons.today, size: context.tokens.icons.md),
                label: const Text(AppMessages.seeToday),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TurnRow extends StatelessWidget {
  const _TurnRow({required this.turn, required this.done});

  final _TurnPreview turn;
  final bool done;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(
        done ? AppIcons.check : turn.icon,
        size: context.tokens.icons.md,
        color: done ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      SizedBox(width: context.tokens.spacing.md),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(turn.title, style: Theme.of(context).textTheme.titleSmall),
            SizedBox(height: context.tokens.spacing.xxxs),
            Text(turn.detail, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      SizedBox(width: context.tokens.spacing.sm),
      Text(turn.duration, style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}

class _SundayCard extends StatelessWidget {
  const _SundayCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(context.tokens.spacing.xl),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: context.tokens.borders.lg,
    ),
    child: Row(
      children: [
        Container(
          width: context.tokens.sizes.sundayIcon,
          height: context.tokens.sizes.sundayIcon,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(
              alpha: context.tokens.opacity.muted,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            AppIcons.rest,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        SizedBox(width: context.tokens.spacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Domingo protegido · 8 nov.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: context.tokens.spacing.xxs),
              Text(
                'Nenhum Turno, nenhum lembrete. O descanso já faz parte do Plano.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ReplanningNote extends StatelessWidget {
  const _ReplanningNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(context.tokens.spacing.xl),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: context.tokens.borders.lg,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          AppIcons.observation,
          color: context.tokens.colors.actionForeground,
        ),
        SizedBox(width: context.tokens.spacing.md),
        Expanded(
          child: Text(
            'Se a semana mudar, o Plano preserva as Revisões e reduz o escopo antes de ocupar o domingo.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ),
  );
}

class _AdjustmentDialog extends StatelessWidget {
  const _AdjustmentDialog();

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(AppMessages.adjustThisWeek),
    content: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: context.tokens.sizes.noteMaxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conte o dia ruim também. O Plano pode mudar sem transformar domingo em dívida.',
          ),
          SizedBox(height: context.tokens.spacing.xl),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(AppIcons.calendar),
            title: const Text(AppMessages.lessTime),
            subtitle: const Text(AppMessages.lessTimeHint),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(AppIcons.questions),
            title: const Text(AppMessages.extraTime),
            subtitle: const Text(AppMessages.extraTimeHint),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text(AppMessages.close),
      ),
    ],
  );
}

Future<void> _showAdjustmentDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => const _AdjustmentDialog(),
);

void _showPreviewMessage(BuildContext context) {
  AppSnackbar.show(context, message: AppMessages.otherWeeksUnavailable);
}

enum _DayStatus { done, today, planned }

class _DayPlan {
  const _DayPlan({
    required this.weekday,
    required this.date,
    required this.duration,
    required this.status,
    required this.entries,
  });

  final String weekday;
  final String date;
  final String duration;
  final _DayStatus status;
  final List<_TurnPreview> entries;
}

class _TurnPreview {
  const _TurnPreview({
    required this.icon,
    required this.title,
    required this.detail,
    required this.duration,
  });

  final IconData icon;
  final String title;
  final String detail;
  final String duration;
}
