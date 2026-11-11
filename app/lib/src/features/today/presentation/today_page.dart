import 'package:flutter/material.dart';

import '../../../core/brand/app_brand.dart';
import '../../../core/content/app_messages.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_ui.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isSunday = now.weekday == DateTime.sunday;

    return AppPageTemplate(
      builder: (context, desktop) => isSunday ? _SundayView(date: now, desktop: desktop) : _TodayContent(date: now),
    );
  }
}

class _TodayContent extends StatelessWidget {
  const _TodayContent({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Header(date: date),
      SizedBox(height: context.tokens.spacing.xxxl),
      const _ConcursosStrip(),
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
            style: context.tokens.typography.headlineSmall,
          ),
          AppButton(
            label: AppMessages.seeAll,
            variant: AppButtonVariant.text,
            onPressed: () {},
          ),
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
  const _Header({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(date),
                  style: context.tokens.typography.headlineLarge,
                ),
                SizedBox(height: context.tokens.spacing.xs),
                Text(
                  '${_formattedDate(date)} · Consolidação',
                  style: context.tokens.typography.bodyMedium.copyWith(
                    color: context.tokens.colors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          AppAccessibleIconButton(
            label: AppMessages.reminders,
            onPressed: () {},
            icon: AppIcons.notification,
          ),
        ],
      ),
      SizedBox(height: context.tokens.spacing.md),
      Text(
        AppBrand.tagline,
        style: context.tokens.typography.bodyLarge.copyWith(
          fontStyle: FontStyle.italic,
          color: context.tokens.colors.onSurfaceMuted,
        ),
      ),
    ],
  );
}

class _ConcursosStrip extends StatelessWidget {
  const _ConcursosStrip();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < context.tokens.layout.narrow;
      final identity = Row(
        children: [
          Container(
            width: context.tokens.sizes.iconContainerMd,
            height: context.tokens.sizes.iconContainerMd,
            decoration: BoxDecoration(
              color: context.tokens.colors.primaryContainer,
              borderRadius: context.tokens.borders.md,
            ),
            child: Icon(
              AppIcons.concursos,
              color: context.tokens.colors.actionForeground,
            ),
          ),
          SizedBox(width: context.tokens.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppMessages.concursoPrioritario,
                  style: context.tokens.typography.labelMedium,
                ),
                SizedBox(height: context.tokens.spacing.xxxs),
                Text(
                  'Analista · 82 dias para a prova',
                  style: context.tokens.typography.titleMedium,
                ),
              ],
            ),
          ),
        ],
      );
      final progress = Column(
        crossAxisAlignment: compact ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            '34% do Edital',
            style: context.tokens.typography.labelMedium,
          ),
          SizedBox(height: context.tokens.spacing.sm),
          LinearProgressIndicator(
            value: .34,
            minHeight: context.tokens.sizes.progressIndicatorThin,
          ),
        ],
      );

      return Container(
        padding: EdgeInsets.all(context.tokens.spacing.lg),
        decoration: BoxDecoration(
          color: context.tokens.colors.card,
          border: Border.all(
            color: context.tokens.colors.border,
          ),
          borderRadius: context.tokens.borders.lg,
        ),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  identity,
                  SizedBox(height: context.tokens.spacing.lg),
                  progress,
                ],
              )
            : Row(
                children: [
                  Expanded(child: identity),
                  SizedBox(width: context.tokens.spacing.lg),
                  SizedBox(
                    width: context.tokens.sizes.compactField,
                    child: progress,
                  ),
                ],
              ),
      );
    },
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
            Container(width: context.tokens.sizes.accentBar, color: context.tokens.colors.primary),
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
                            style: context.tokens.typography.headlineSmall,
                          ),
                        ),
                        Text(
                          '1h40',
                          style: context.tokens.typography.titleMedium,
                        ),
                      ],
                    ),
                    SizedBox(height: context.tokens.spacing.xxs),
                    Text(
                      'Comece pela disciplina principal. Um turno de cada vez.',
                      style: context.tokens.typography.bodyMedium,
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
                      child: AppButton(
                        onPressed: () {},
                        icon: AppIcons.play,
                        label: AppMessages.startNextTurn,
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
            color: current ? context.tokens.colors.primaryContainer : context.tokens.colors.surfaceSubtle,
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
              Text(title, style: context.tokens.typography.titleSmall),
              Text(subtitle, style: context.tokens.typography.bodySmall),
            ],
          ),
        ),
        SizedBox(width: context.tokens.spacing.sm),
        Text(duration, style: context.tokens.typography.labelMedium),
      ],
    ),
  );
}

class _NotebookDivider extends StatelessWidget {
  const _NotebookDivider();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: context.tokens.spacing.huge),
    child: const AppDivider(margin: EdgeInsets.zero),
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
                  style: context.tokens.typography.titleLarge,
                ),
              ),
            ],
          ),
          SizedBox(height: context.tokens.spacing.xs),
          Text(
            AppMessages.weeklyRhythm,
            style: context.tokens.typography.bodySmall,
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
              color: context.tokens.colors.successContainer,
              borderRadius: context.tokens.borders.md,
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.rest,
                  size: context.tokens.icons.md,
                  color: context.tokens.colors.success,
                ),
                SizedBox(width: context.tokens.spacing.md),
                Expanded(
                  child: Text(
                    AppMessages.protectedSundayDescription,
                    style: context.tokens.typography.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.tokens.spacing.xl),
          Text(
            'Fundação concluída',
            style: context.tokens.typography.labelMedium,
          ),
          SizedBox(height: context.tokens.spacing.sm),
          LinearProgressIndicator(
            value: .62,
            minHeight: context.tokens.sizes.progressIndicatorThin,
          ),
          SizedBox(height: context.tokens.spacing.xs),
          Text('Semana 8 de 13', style: context.tokens.typography.bodySmall),
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
    final primary = context.tokens.colors.primary;
    final isDone = state == _DayState.done;
    final isToday = state == _DayState.today;
    final isRest = state == _DayState.rest;
    return Column(
      children: [
        Text(day, style: context.tokens.typography.labelSmall),
        SizedBox(height: context.tokens.spacing.sm),
        Container(
          width: context.tokens.sizes.dayMarker,
          height: context.tokens.sizes.dayMarker,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? primary
                : isRest
                ? context.tokens.colors.successContainer
                : context.tokens.colors.transparent,
            border: Border.all(
              color: isToday ? primary : context.tokens.colors.controlOutline,
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
                    style: context.tokens.typography.labelMedium.copyWith(
                      color: color,
                    ),
                  ),
                ),
                Text(duration, style: context.tokens.typography.labelMedium),
              ],
            ),
            SizedBox(height: context.tokens.spacing.lg),
            Text(title, style: context.tokens.typography.titleMedium),
            SizedBox(height: context.tokens.spacing.xxs),
            Text(detail, style: context.tokens.typography.bodySmall),
            SizedBox(height: context.tokens.spacing.lg),
            Row(
              children: [
                Icon(AppIcons.reviews, size: context.tokens.icons.md, color: color),
                SizedBox(width: context.tokens.spacing.xs),
                Text(when, style: context.tokens.typography.labelMedium),
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
      color: context.tokens.colors.surfaceSubtle.withValues(
        alpha: context.tokens.opacity.muted,
      ),
      borderRadius: context.tokens.borders.lg,
      border: Border.all(color: context.tokens.colors.border),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(AppIcons.fromMemory, color: context.tokens.colors.actionForeground),
        SizedBox(width: context.tokens.spacing.md),
        Expanded(
          child: Text(
            'Recuperação ativa antes de tudo: feche o material e tente dizer antes de conferir.',
            style: context.tokens.typography.bodyMedium,
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
                      color: context.tokens.colors.successContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.rest,
                      size: context.tokens.icons.hero,
                      color: context.tokens.colors.success,
                    ),
                  ),
                  SizedBox(height: context.tokens.spacing.xxl),
                  Text(
                    AppMessages.protectedSunday,
                    style: context.tokens.typography.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.tokens.spacing.md),
                  Text(
                    AppMessages.protectedSundayToday,
                    style: context.tokens.typography.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.tokens.spacing.xl),
                  Text(
                    _formattedDate(date),
                    style: context.tokens.typography.labelMedium,
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
