import 'package:flutter/material.dart';

import '../../../core/presentation/app_shell.dart';
import '../../../core/theme/app_theme.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isSunday = now.weekday == DateTime.sunday;

    return AppShell(
      section: AppSection.today,
      builder: (context, desktop) => SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                desktop ? 40 : 20,
                20,
                desktop ? 40 : 20,
                48,
              ),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: isSunday
                        ? _SundayView(date: now, desktop: desktop)
                        : _TodayContent(date: now, desktop: desktop),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
      const SizedBox(height: 28),
      const _HorizonStrip(),
      const SizedBox(height: 24),
      LayoutBuilder(
        builder: (context, constraints) {
          final twoColumns = constraints.maxWidth >= 820;
          final plan = const _DailyPlanCard();
          final rhythm = const _SunnyDaysCard();
          if (!twoColumns) {
            return Column(children: [plan, const SizedBox(height: 20), rhythm]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: plan),
              const SizedBox(width: 20),
              Expanded(flex: 4, child: rhythm),
            ],
          );
        },
      ),
      const SizedBox(height: 32),
      Row(
        children: [
          Text(
            'Revisões para hoje',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Spacer(),
          TextButton(onPressed: () {}, child: const Text('Ver todos')),
        ],
      ),
      const SizedBox(height: 12),
      const _ReviewCards(),
      const SizedBox(height: 32),
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
        const AppBrandLogo(width: 178),
        const SizedBox(height: 28),
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
                const SizedBox(height: 6),
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
            tooltip: 'Lembretes',
            onPressed: () {},
            icon: Icon(AppIcons.notification, size: AppIcons.standard),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        'Cada manhã conta.',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontStyle: FontStyle.italic,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}

class _HorizonStrip extends StatelessWidget {
  const _HorizonStrip();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            AppIcons.horizons,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Horizonte principal',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 2),
              Text(
                'Analista · 82 dias para a prova',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '34% do Edital',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 7),
              const LinearProgressIndicator(value: .34, minHeight: 6),
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
      borderRadius: BorderRadius.circular(12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: Theme.of(context).colorScheme.primary),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Sua alvorada',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        Text(
                          '1h40',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Comece pela disciplina principal. Um turno de cada vez.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    const _PlanRow(
                      icon: AppIcons.bookText,
                      duration: '50 min',
                      title: 'Direito Constitucional',
                      subtitle:
                          'Leitura corrida · Controle de constitucionalidade',
                      current: true,
                    ),
                    const _NotebookDivider(),
                    _PlanRow(
                      icon: AppIcons.fromMemory,
                      duration: '10 min',
                      title: 'De cabeça',
                      subtitle: 'Cinco linhas com o material fechado',
                    ),
                    const _NotebookDivider(),
                    _PlanRow(
                      icon: AppIcons.questions,
                      duration: '30 min',
                      title: 'Questões',
                      subtitle: '20 a 30 questões do tópico',
                    ),
                    const _NotebookDivider(),
                    _PlanRow(
                      icon: AppIcons.errorNotebook,
                      duration: '10 min',
                      title: 'Caderno de Erros',
                      subtitle: 'Registre o motivo de cada erro',
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: Icon(AppIcons.play, size: AppIcons.compact),
                        label: const Text('Começar próximo turno'),
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
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: current
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 21,
            color: current ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(duration, style: Theme.of(context).textTheme.labelMedium),
      ],
    ),
  );
}

class _NotebookDivider extends StatelessWidget {
  const _NotebookDivider();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 52),
    child: Divider(
      height: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    ),
  );
}

class _SunnyDaysCard extends StatelessWidget {
  const _SunnyDaysCard();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.sunnyDays,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Dias de sol',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Seu ritmo nesta semana',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 22),
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
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.rest,
                  size: 22,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Domingo é descanso. Ele já faz parte do método.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Fundação concluída',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 7),
          const LinearProgressIndicator(value: .62, minHeight: 6),
          const SizedBox(height: 6),
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
        const SizedBox(height: 7),
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? primary
                : isRest
                ? Theme.of(context).colorScheme.secondaryContainer
                : Colors.transparent,
            border: Border.all(
              color: isToday ? primary : Theme.of(context).colorScheme.outline,
            ),
          ),
          child: isDone
              ? Icon(AppIcons.check, size: 15, color: AppColors.tinta)
              : isRest
              ? Icon(AppIcons.rest, size: 14)
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
      final width = constraints.maxWidth >= 820
          ? (constraints.maxWidth - 32) / 3
          : constraints.maxWidth;
      return Wrap(
        spacing: 16,
        runSpacing: 12,
        children: [
          _ReviewCard(
            width: width,
            interval: '1 dia',
            when: 'Amanhã',
            duration: '3 min',
            title: 'Princípios fundamentais',
            detail: 'Memorize + Atenção',
            color: AppColors.sol,
          ),
          _ReviewCard(
            width: width,
            interval: '7 dias',
            when: '7 dias',
            duration: '10 min',
            title: 'Poder constituinte',
            detail: 'Caixas + De cabeça',
            color: AppColors.jurisprudenciaTinta,
          ),
          _ReviewCard(
            width: width,
            interval: '30 dias',
            when: '30 dias',
            duration: '20 min',
            title: 'Direitos fundamentais',
            detail: '20 questões',
            color: AppColors.salviaTexto,
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
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Revisão de $interval',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: color),
                  ),
                ),
                const Spacer(),
                Text(duration, style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 3),
            Text(detail, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(AppIcons.reviews, size: 18, color: color),
                const SizedBox(width: 6),
                Text(when, style: Theme.of(context).textTheme.labelMedium),
                const Spacer(),
                const Icon(AppIcons.arrowRight, size: 18),
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
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: .55),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(AppIcons.fromMemory, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
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
      if (!desktop) const AppBrandLogo(width: 178),
      SizedBox(height: desktop ? 72 : 48),
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.rest,
                      size: 34,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Domingo protegido',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Hoje a manhã é sua. O descanso já está no plano.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
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
