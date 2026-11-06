import 'package:flutter/material.dart';

import '../../../core/presentation/app_shell.dart';
import '../../../core/theme/app_theme.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  static const _reviews = [
    _ReviewPreview(
      interval: '1 dia',
      title: 'Princípios fundamentais',
      discipline: 'Direito Constitucional',
      horizon: 'Analista Legislativo',
      duration: '3 min',
      instruction: 'Leia somente as caixas Memorize e Atenção.',
      detail: 'Recupere a ideia antes de abrir cada caixa.',
      type: _ReviewType.oneDay,
    ),
    _ReviewPreview(
      interval: '7 dias',
      title: 'Poder constituinte',
      discipline: 'Direito Constitucional',
      horizon: 'Analista Legislativo',
      duration: '10 min',
      instruction: 'Caixas, quadro comparativo e cinco linhas De cabeça.',
      detail: 'O material fica fechado até terminar o De cabeça.',
      type: _ReviewType.sevenDays,
    ),
    _ReviewPreview(
      interval: '30 dias',
      title: 'Direitos fundamentais',
      discipline: 'Direito Constitucional',
      horizon: 'Analista Legislativo',
      duration: '20 min',
      instruction: 'Responda 20 questões do Tópico.',
      detail: 'Acima de 80%, o Tópico fica Fixado.',
      type: _ReviewType.thirtyDays,
    ),
  ];

  @override
  Widget build(BuildContext context) => AppShell(
    section: AppSection.reviews,
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
                  child: _ReviewsContent(reviews: _reviews, desktop: desktop),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ReviewsContent extends StatelessWidget {
  const _ReviewsContent({required this.reviews, required this.desktop});

  final List<_ReviewPreview> reviews;
  final bool desktop;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (!desktop) ...[
        const AppBrandLogo(width: 178),
        const SizedBox(height: 28),
      ],
      const _Header(),
      const SizedBox(height: 28),
      const _Overview(),
      const SizedBox(height: 24),
      const _Filters(),
      const SizedBox(height: 20),
      LayoutBuilder(
        builder: (context, constraints) {
          final twoColumns = constraints.maxWidth >= 860;
          final queue = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Revisões para hoje',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 5),
              Text(
                'Faça na ordem. Cada intervalo pede uma atividade diferente.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              for (var index = 0; index < reviews.length; index++) ...[
                _ReviewCard(review: reviews[index]),
                if (index < reviews.length - 1) const SizedBox(height: 14),
              ],
            ],
          );
          const guide = _MethodGuide();

          if (!twoColumns) {
            return Column(children: [queue, const SizedBox(height: 24), guide]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: queue),
              const SizedBox(width: 20),
              const Expanded(flex: 4, child: guide),
            ],
          );
        },
      ),
      const SizedBox(height: 28),
      const _UpcomingReviews(),
    ],
  );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 620;
      final title = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revisões', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 6),
          Text(
            'Revise no momento certo, do jeito certo.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
      final button = OutlinedButton.icon(
        onPressed: () => _showMethodDialog(context),
        icon: const Icon(AppIcons.observation, size: AppIcons.compact),
        label: const Text('Como funciona'),
      );

      if (compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [title, const SizedBox(height: 18), button],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: title),
          button,
        ],
      );
    },
  );
}

class _Overview extends StatelessWidget {
  const _Overview();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Wrap(
      spacing: 32,
      runSpacing: 16,
      children: [
        _OverviewItem(
          icon: AppIcons.reviews,
          value: '3',
          label: 'Revisões para hoje',
        ),
        _OverviewItem(
          icon: AppIcons.mockExam,
          value: '33 min',
          label: 'Tempo previsto',
        ),
        _OverviewItem(
          icon: AppIcons.calendar,
          value: '7',
          label: 'Revisões nesta semana',
        ),
      ],
    ),
  );
}

class _OverviewItem extends StatelessWidget {
  const _OverviewItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 240,
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleMedium),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Filters extends StatelessWidget {
  const _Filters();

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        const FilterChip(
          selected: true,
          onSelected: null,
          label: Text('Todas'),
        ),
        const SizedBox(width: 8),
        FilterChip(
          selected: false,
          onSelected: (_) => _showFilterMessage(context),
          label: const Text('1 dia'),
        ),
        const SizedBox(width: 8),
        FilterChip(
          selected: false,
          onSelected: (_) => _showFilterMessage(context),
          label: const Text('7 dias'),
        ),
        const SizedBox(width: 8),
        FilterChip(
          selected: false,
          onSelected: (_) => _showFilterMessage(context),
          label: const Text('30 dias'),
        ),
        const SizedBox(width: 8),
        FilterChip(
          avatar: const Icon(AppIcons.horizons, size: 16),
          selected: false,
          onSelected: (_) => _showFilterMessage(context),
          label: const Text('Todos os Horizontes'),
        ),
      ],
    ),
  );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final _ReviewPreview review;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = switch (review.type) {
      _ReviewType.oneDay => scheme.primary,
      _ReviewType.sevenDays => scheme.tertiary,
      _ReviewType.thirtyDays => scheme.secondary,
    };
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 6, height: 260, color: accent),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: .14),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Revisão de ${review.interval}',
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(color: accent),
                        ),
                      ),
                      Text(
                        review.duration,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    review.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${review.discipline} · ${review.horizon}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withValues(
                        alpha: .5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _instructionIcon(review.type),
                          size: 20,
                          color: accent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.instruction,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                review.detail,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () => _showReviewDialog(context, review),
                      icon: const Icon(AppIcons.play, size: 18),
                      label: const Text('Começar revisão'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodGuide extends StatelessWidget {
  const _MethodGuide();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          AppIcons.reviews,
          size: AppIcons.prominent,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 14),
        Text(
          'Uma Revisão, uma função',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'O intervalo muda e a atividade também. Não transforme Revisão em releitura completa.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        const _GuideStep(
          interval: '1 dia',
          duration: '2 a 3 min',
          action: 'Memorize + Atenção',
        ),
        const _GuideStep(
          interval: '7 dias',
          duration: '8 a 10 min',
          action: 'Caixas + comparativos + De cabeça',
        ),
        const _GuideStep(
          interval: '30 dias',
          duration: '20 min',
          action: '20 questões do Tópico',
          last: true,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                AppIcons.rest,
                size: 19,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'No domingo, nenhuma Revisão é cobrada ou enviada por lembrete.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.interval,
    required this.duration,
    required this.action,
    this.last = false,
  });

  final String interval;
  final String duration;
  final String action;
  final bool last;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                interval.split(' ').first,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            if (!last)
              Expanded(
                child: Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      interval,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Spacer(),
                    Text(
                      duration,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(action, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _UpcomingReviews extends StatelessWidget {
  const _UpcomingReviews();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Próximas Revisões',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 14),
        const _UpcomingRow(
          date: 'Sáb., 7 nov.',
          count: '2 Revisões',
          duration: '23 min',
        ),
        const Divider(height: 24),
        const _UpcomingRow(
          date: 'Seg., 9 nov.',
          count: '4 Revisões',
          duration: '36 min',
        ),
        const Divider(height: 24),
        const _UpcomingRow(
          date: 'Ter., 10 nov.',
          count: '1 Revisão',
          duration: '10 min',
        ),
      ],
    ),
  );
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({
    required this.date,
    required this.count,
    required this.duration,
  });

  final String date;
  final String count;
  final String duration;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(
        AppIcons.calendar,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(date, style: Theme.of(context).textTheme.titleSmall),
      ),
      Text(count, style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(width: 16),
      SizedBox(
        width: 48,
        child: Text(
          duration,
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: TextAlign.end,
        ),
      ),
    ],
  );
}

class _ReviewDialog extends StatelessWidget {
  const _ReviewDialog({required this.review});

  final _ReviewPreview review;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Revisão de ${review.interval}'),
    content: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 450),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(review.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(review.instruction),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(AppIcons.mockExam, size: 18),
              const SizedBox(width: 8),
              Text('${review.duration} previstos'),
            ],
          ),
          const SizedBox(height: 12),
          Text(review.detail, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Agora não'),
      ),
      FilledButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Começar'),
      ),
    ],
  );
}

Future<void> _showReviewDialog(BuildContext context, _ReviewPreview review) =>
    showDialog<void>(
      context: context,
      builder: (context) => _ReviewDialog(review: review),
    );

Future<void> _showMethodDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Como funcionam as Revisões'),
    content: const Text(
      'Cada Tópico volta em 1, 7 e 30 dias. A atividade muda em cada intervalo para recuperar antes de reler.',
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Entendi'),
      ),
    ],
  ),
);

void _showFilterMessage(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text('Os filtros serão conectados aos dados depois.'),
      ),
    );
}

IconData _instructionIcon(_ReviewType type) => switch (type) {
  _ReviewType.oneDay => AppIcons.memorize,
  _ReviewType.sevenDays => AppIcons.fromMemory,
  _ReviewType.thirtyDays => AppIcons.questions,
};

enum _ReviewType { oneDay, sevenDays, thirtyDays }

class _ReviewPreview {
  const _ReviewPreview({
    required this.interval,
    required this.title,
    required this.discipline,
    required this.horizon,
    required this.duration,
    required this.instruction,
    required this.detail,
    required this.type,
  });

  final String interval;
  final String title;
  final String discipline;
  final String horizon;
  final String duration;
  final String instruction;
  final String detail;
  final _ReviewType type;
}
