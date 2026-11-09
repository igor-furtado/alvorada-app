import 'package:flutter/material.dart';

import '../../../core/brand/app_brand.dart';
import '../../../core/content/app_messages.dart';
import '../../../core/presentation/app_shell.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_ui.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isSunday = now.weekday == DateTime.sunday;

    return AppPageTemplate(
      builder: (context, desktop) =>
          isSunday ? _SundayView(date: now, desktop: desktop) : _TodayContent(date: now, desktop: desktop),
    );
  }
}

class _TodayContent extends StatelessWidget {
  const _TodayContent({required this.date, required this.desktop});
  final DateTime date;
  final bool desktop;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Header(date: date, showBrand: !desktop),
      SizedBox(height: context.tokens.spacing.xxxl),
      const _ContestStrip(),
      SizedBox(height: context.tokens.spacing.xxl),
      LayoutBuilder(
        builder: (context, constraints) {
          final twoColumns = constraints.maxWidth >= context.tokens.layout.detail;
          const plan = _DailyPlanCard();
          const rhythm = _SunnyDaysCard();
          if (!twoColumns) {
            return Column(
              children: [
                plan,
                SizedBox(height: context.tokens.spacing.xl),
                rhythm,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(flex: 7, child: plan),
              SizedBox(width: context.tokens.spacing.xl),
              const Expanded(flex: 4, child: rhythm),
            ],
          );
        },
      ),
      SizedBox(height: context.tokens.spacing.xxxl),
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: context.tokens.spacing.md,
        runSpacing: context.tokens.spacing.xs,
        children: [
          Text(
            AppMessages.reviewsForToday,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          TextButton(onPressed: () {}, child: const Text(AppMessages.seeAll)),
        ],
      ),
      SizedBox(height: context.tokens.spacing.md),
      const _ReviewCards(),
      SizedBox(height: context.tokens.spacing.xxxl),
      const _MethodNote(),
    ],
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.date, required this.showBrand});
  final DateTime date;
  final bool showBrand;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (showBrand) ...[
        AppBrandLogo(width: context.tokens.layout.brandWidth),
        SizedBox(height: context.tokens.spacing.xxxl),
      ],
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(date),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                SizedBox(height: context.tokens.spacing.xs),
                Text(
                  '${_formattedDate(date)} · Consolidação',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: AppMessages.reminders,
            onPressed: () {},
            icon: Icon(AppIcons.notification, size: context.tokens.icons.lg),
          ),
        ],
      ),
      SizedBox(height: context.tokens.spacing.md),
      Text(
        AppBrand.tagline,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontStyle: FontStyle.italic,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}

class _ContestStrip extends StatelessWidget {
  const _ContestStrip();

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(context.tokens.spacing.lg),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: context.tokens.borders.lg,
    ),
    child: Row(
      children: [
        Container(
          width: context.tokens.sizes.iconContainerMd,
          height: context.tokens.sizes.iconContainerMd,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: context.tokens.borders.md,
          ),
          child: Icon(
            AppIcons.contests,
            color: context.tokens.colors.actionForeground,
          ),
        ),
        SizedBox(width: context.tokens.spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppMessages.mainContest,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              SizedBox(height: context.tokens.spacing.xxxs),
              Text(
                'Analista · 82 dias para a prova',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        SizedBox(width: context.tokens.spacing.lg),
        SizedBox(
          width: context.tokens.sizes.compactField,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '34% do Edital',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              SizedBox(height: context.tokens.spacing.sm),
              LinearProgressIndicator(
                value: .34,
                minHeight: context.tokens.sizes.progressIndicatorThin,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DailyPlanCard extends StatelessWidget {
  const _DailyPlanCard();

  @override
  Widget build(BuildContext context) => Card(
    child: ClipRRect(
      borderRadius: context.tokens.borders.lg,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: context.tokens.sizes.accentBar, color: Theme.of(context).colorScheme.primary),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(context.tokens.spacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppMessages.todayPlanTitle,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        Text(
                          '1h40',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: context.tokens.spacing.xxs),
                    Text(
                      'Comece pela disciplina principal. Um turno de cada vez.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: context.tokens.spacing.xl),
                    const _PlanRow(
                      icon: AppIcons.bookText,
                      duration: '50 min',
                      title: 'Direito Constitucional',
                      subtitle: 'Leitura corrida · Controle de constitucionalidade',
                      current: true,
                    ),
                    const _NotebookDivider(),
                    const _PlanRow(
                      icon: AppIcons.fromMemory,
                      duration: '10 min',
                      title: 'De cabeça',
                      subtitle: 'Cinco linhas com o material fechado',
                    ),
                    const _NotebookDivider(),
                    const _PlanRow(
                      icon: AppIcons.questions,
                      duration: '30 min',
                      title: 'Questões',
                      subtitle: '20 a 30 questões do tópico',
                    ),
                    const _NotebookDivider(),
                    const _PlanRow(
                      icon: AppIcons.errorNotebook,
                      duration: '10 min',
                      title: 'Caderno de Erros',
                      subtitle: 'Registre o motivo de cada erro',
                    ),
                    SizedBox(height: context.tokens.spacing.xxl),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          AppIcons.play,
                          size: context.tokens.icons.md,
                        ),
                        label: const Text(AppMessages.startNextTurn),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.icon,
    required this.duration,
    required this.title,
    required this.subtitle,
    this.current = false,
  });

  final IconData icon;
  final String duration;
  final String title;
  final String subtitle;
  final bool current;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: context.tokens.spacing.sm),
    child: Row(
      children: [
        Container(
          width: context.tokens.sizes.iconContainerSm,
          height: context.tokens.sizes.iconContainerSm,
          decoration: BoxDecoration(
            color: current
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: context.tokens.borders.md,
          ),
          child: Icon(
            icon,
            size: context.tokens.icons.md,
            color: current ? context.tokens.colors.actionForeground : null,
          ),
        ),
        SizedBox(width: context.tokens.spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        SizedBox(width: context.tokens.spacing.sm),
        Text(duration, style: Theme.of(context).textTheme.labelMedium),
      ],
    ),
  );
}

class _NotebookDivider extends StatelessWidget {
  const _NotebookDivider();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: context.tokens.spacing.huge),
    child: Divider(
      height: context.tokens.sizes.hairline,
      color: Theme.of(context).colorScheme.outlineVariant,
    ),
  );
}

class _SunnyDaysCard extends StatelessWidget {
  const _SunnyDaysCard();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: EdgeInsets.all(context.tokens.spacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.sunnyDays,
                color: context.tokens.colors.actionForeground,
              ),
              SizedBox(width: context.tokens.spacing.sm),
              Flexible(
                child: Text(
                  AppMessages.sunnyDays,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          SizedBox(height: context.tokens.spacing.xs),
          Text(
            AppMessages.weeklyRhythm,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: context.tokens.spacing.xxl),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DayMark(day: 'S', state: _DayState.done),
              _DayMark(day: 'T', state: _DayState.done),
              _DayMark(day: 'Q', state: _DayState.done),
              _DayMark(day: 'Q', state: _DayState.today),
              _DayMark(day: 'S', state: _DayState.next),
              _DayMark(day: 'S', state: _DayState.next),
              _DayMark(day: 'D', state: _DayState.rest),
            ],
          ),
          SizedBox(height: context.tokens.spacing.xl),
          Container(
            padding: EdgeInsets.all(context.tokens.spacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: context.tokens.borders.md,
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.rest,
                  size: context.tokens.icons.md,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(width: context.tokens.spacing.md),
                Expanded(
                  child: Text(
                    AppMessages.protectedSundayDescription,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.tokens.spacing.xl),
          Text(
            'Fundação concluída',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          SizedBox(height: context.tokens.spacing.sm),
          LinearProgressIndicator(
            value: .62,
            minHeight: context.tokens.sizes.progressIndicatorThin,
          ),
          SizedBox(height: context.tokens.spacing.xs),
          Text('Semana 8 de 13', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}

enum _DayState { done, today, next, rest }

class _DayMark extends StatelessWidget {
  const _DayMark({required this.day, required this.state});
  final String day;
  final _DayState state;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDone = state == _DayState.done;
    final isToday = state == _DayState.today;
    final isRest = state == _DayState.rest;
    return Column(
      children: [
        Text(day, style: Theme.of(context).textTheme.labelSmall),
        SizedBox(height: context.tokens.spacing.sm),
        Container(
          width: context.tokens.sizes.dayMarker,
          height: context.tokens.sizes.dayMarker,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? primary
                : isRest
                ? Theme.of(context).colorScheme.secondaryContainer
                : context.tokens.colors.transparent,
            border: Border.all(
              color: isToday ? primary : Theme.of(context).colorScheme.outline,
            ),
          ),
          child: isDone
              ? Icon(
                  AppIcons.check,
                  size: context.tokens.icons.sm,
                  color: context.tokens.colors.onPrimary,
                )
              : isRest
              ? Icon(AppIcons.rest, size: context.tokens.icons.sm)
              : null,
        ),
      ],
    );
  }
}

class _ReviewCards extends StatelessWidget {
  const _ReviewCards();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth >= context.tokens.layout.detail
          ? (constraints.maxWidth - context.tokens.spacing.xxxl) / 3
          : constraints.maxWidth;
      return Wrap(
        spacing: context.tokens.spacing.lg,
        runSpacing: context.tokens.spacing.md,
        children: [
          _ReviewCard(
            width: width,
            interval: '1 dia',
            when: 'Amanhã',
            duration: '3 min',
            title: 'Princípios fundamentais',
            detail: 'Memorize + Atenção',
            color: context.tokens.colors.primary,
          ),
          _ReviewCard(
            width: width,
            interval: '7 dias',
            when: '7 dias',
            duration: '10 min',
            title: 'Poder constituinte',
            detail: 'Caixas + De cabeça',
            color: context.tokens.colors.info,
          ),
          _ReviewCard(
            width: width,
            interval: '30 dias',
            when: '30 dias',
            duration: '20 min',
            title: 'Direitos fundamentais',
            detail: '20 questões',
            color: context.tokens.colors.success,
          ),
        ],
      );
    },
  );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.width,
    required this.interval,
    required this.when,
    required this.duration,
    required this.title,
    required this.detail,
    required this.color,
  });
  final double width;
  final String interval;
  final String when;
  final String duration;
  final String title;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Card(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: context.tokens.spacing.sm,
              runSpacing: context.tokens.spacing.xs,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.tokens.spacing.sm,
                    vertical: context.tokens.spacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: context.tokens.opacity.tint),
                    borderRadius: context.tokens.borders.sm,
                  ),
                  child: Text(
                    'Revisão de $interval',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: color),
                  ),
                ),
                Text(duration, style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            SizedBox(height: context.tokens.spacing.lg),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: context.tokens.spacing.xxs),
            Text(detail, style: Theme.of(context).textTheme.bodySmall),
            SizedBox(height: context.tokens.spacing.lg),
            Row(
              children: [
                Icon(AppIcons.reviews, size: context.tokens.icons.md, color: color),
                SizedBox(width: context.tokens.spacing.xs),
                Text(when, style: Theme.of(context).textTheme.labelMedium),
                const Spacer(),
                Icon(AppIcons.arrowRight, size: context.tokens.icons.md),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _MethodNote extends StatelessWidget {
  const _MethodNote();

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(context.tokens.spacing.xl),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
        alpha: context.tokens.opacity.muted,
      ),
      borderRadius: context.tokens.borders.lg,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(AppIcons.fromMemory, color: context.tokens.colors.actionForeground),
        SizedBox(width: context.tokens.spacing.md),
        Expanded(
          child: Text(
            'Recuperação ativa antes de tudo: feche o material e tente dizer antes de conferir.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ),
  );
}

class _SundayView extends StatelessWidget {
  const _SundayView({required this.date, required this.desktop});
  final DateTime date;
  final bool desktop;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (!desktop) AppBrandLogo(width: context.tokens.layout.brandWidth),
      SizedBox(
        height: desktop ? context.tokens.layout.sundayContentOffset : context.tokens.spacing.huge,
      ),
      Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.tokens.layout.dialogMaxWidth),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(context.tokens.spacing.page),
              child: Column(
                children: [
                  Container(
                    width: context.tokens.sizes.largeVisual,
                    height: context.tokens.sizes.largeVisual,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.rest,
                      size: context.tokens.icons.hero,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  SizedBox(height: context.tokens.spacing.xxl),
                  Text(
                    AppMessages.protectedSunday,
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.tokens.spacing.md),
                  Text(
                    AppMessages.protectedSundayToday,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.tokens.spacing.xl),
                  Text(
                    _formattedDate(date),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

String _greeting(DateTime date) {
  if (date.hour < 12) return 'Bom dia.';
  if (date.hour < 18) return 'Boa tarde.';
  return 'Boa noite.';
}

String _formattedDate(DateTime date) {
  const weekdays = [
    'segunda-feira',
    'terça-feira',
    'quarta-feira',
    'quinta-feira',
    'sexta-feira',
    'sábado',
    'domingo',
  ];
  const months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];
  return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
}
