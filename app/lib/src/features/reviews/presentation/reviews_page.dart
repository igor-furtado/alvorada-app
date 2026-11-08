import 'package:flutter/material.dart';

import '../../../core/presentation/app_shell.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_ui.dart';

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
  Widget build(BuildContext context) => AppPageTemplate(
    section: AppSection.reviews,
    builder: (context, desktop) => _ReviewsContent(reviews: _reviews, desktop: desktop),
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
        AppBrandLogo(width: context.tokens.layout.brandWidth),
        SizedBox(height: context.tokens.spacing.xxxl),
      ],
      const _Header(),
      SizedBox(height: context.tokens.spacing.xxxl),
      const AppMetricOverview(
        items: [
          AppMetricData(icon: AppIcons.reviews, value: '3', label: 'Revisões para hoje'),
          AppMetricData(icon: AppIcons.mockExam, value: '33 min', label: 'Tempo previsto'),
          AppMetricData(icon: AppIcons.calendar, value: '7', label: 'Revisões nesta semana'),
        ],
      ),
      SizedBox(height: context.tokens.spacing.xxl),
      const _Filters(),
      SizedBox(height: context.tokens.spacing.xl),
      LayoutBuilder(
        builder: (context, constraints) {
          final twoColumns = constraints.maxWidth >= context.tokens.layout.contentSplit;
          final queue = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Revisões para hoje',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: context.tokens.spacing.xs),
              Text(
                'Faça na ordem. Cada intervalo pede uma atividade diferente.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: context.tokens.spacing.lg),
              for (var index = 0; index < reviews.length; index++) ...[
                _ReviewCard(review: reviews[index]),
                if (index < reviews.length - 1) SizedBox(height: context.tokens.spacing.lg),
              ],
            ],
          );
          const guide = _MethodGuide();

          if (!twoColumns) {
            return Column(
              children: [
                queue,
                SizedBox(height: context.tokens.spacing.xxl),
                guide,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: queue),
              SizedBox(width: context.tokens.spacing.xl),
              const Expanded(flex: 4, child: guide),
            ],
          );
        },
      ),
      SizedBox(height: context.tokens.spacing.xxxl),
      const _UpcomingReviews(),
    ],
  );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < context.tokens.layout.toolbar;
      final title = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revisões', style: Theme.of(context).textTheme.headlineLarge),
          SizedBox(height: context.tokens.spacing.xs),
          Text(
            'Revise no momento certo, do jeito certo.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
      final button = AppButton(
        onPressed: () => _showMethodDialog(context),
        variant: AppButtonVariant.outline,
        icon: AppIcons.observation,
        label: 'Como funciona',
      );

      if (compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            title,
            SizedBox(height: context.tokens.spacing.xl),
            button,
          ],
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
        SizedBox(width: context.tokens.spacing.sm),
        FilterChip(
          selected: false,
          onSelected: (_) => _showFilterMessage(context),
          label: const Text('1 dia'),
        ),
        SizedBox(width: context.tokens.spacing.sm),
        FilterChip(
          selected: false,
          onSelected: (_) => _showFilterMessage(context),
          label: const Text('7 dias'),
        ),
        SizedBox(width: context.tokens.spacing.sm),
        FilterChip(
          onSelected: (_) => _showFilterMessage(context),
          label: const Text('30 dias'),
        ),
        SizedBox(width: context.tokens.spacing.sm),
        FilterChip(
          avatar: Icon(AppIcons.horizons, size: context.tokens.icons.sm),
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
        borderRadius: context.tokens.borders.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: context.tokens.sizes.accentBar,
            height: context.tokens.sizes.reviewAccentHeight,
            color: accent,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(context.tokens.spacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: context.tokens.spacing.md,
                    runSpacing: context.tokens.spacing.sm,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.tokens.spacing.md,
                          vertical: context.tokens.spacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(
                            alpha: context.tokens.opacity.tintStrong,
                          ),
                          borderRadius: context.tokens.borders.sm,
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
                  SizedBox(height: context.tokens.spacing.lg),
                  Text(
                    review.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: context.tokens.spacing.xxs),
                  Text(
                    '${review.discipline} · ${review.horizon}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SizedBox(height: context.tokens.spacing.lg),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(context.tokens.spacing.md),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withValues(
                        alpha: context.tokens.opacity.half,
                      ),
                      borderRadius: context.tokens.borders.md,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _instructionIcon(review.type),
                          size: context.tokens.icons.md,
                          color: accent,
                        ),
                        SizedBox(width: context.tokens.spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.instruction,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              SizedBox(height: context.tokens.spacing.xxs),
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
                  SizedBox(height: context.tokens.spacing.lg),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () => _showReviewDialog(context, review),
                      icon: Icon(AppIcons.play, size: context.tokens.icons.md),
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
    padding: EdgeInsets.all(context.tokens.spacing.xl),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: context.tokens.borders.lg,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          AppIcons.reviews,
          size: context.tokens.icons.xl,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: context.tokens.spacing.lg),
        Text(
          'Uma Revisão, uma função',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: context.tokens.spacing.sm),
        Text(
          'O intervalo muda e a atividade também. Não transforme Revisão em releitura completa.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: context.tokens.spacing.xl),
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
        SizedBox(height: context.tokens.spacing.lg),
        Container(
          padding: EdgeInsets.all(context.tokens.spacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: context.tokens.borders.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                AppIcons.rest,
                size: context.tokens.icons.md,
                color: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(width: context.tokens.spacing.md),
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
              width: context.tokens.sizes.stepIndicator,
              height: context.tokens.sizes.stepIndicator,
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
                  width: context.tokens.sizes.hairline,
                  margin: EdgeInsets.symmetric(vertical: context.tokens.spacing.xxs),
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
          ],
        ),
        SizedBox(width: context.tokens.spacing.md),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: context.tokens.spacing.xl),
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
                SizedBox(height: context.tokens.spacing.xxs),
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
    padding: EdgeInsets.all(context.tokens.spacing.xl),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: context.tokens.borders.lg,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Próximas Revisões',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: context.tokens.spacing.lg),
        const _UpcomingRow(
          date: 'Sáb., 7 nov.',
          count: '2 Revisões',
          duration: '23 min',
        ),
        Divider(height: context.tokens.spacing.xxl),
        const _UpcomingRow(
          date: 'Seg., 9 nov.',
          count: '4 Revisões',
          duration: '36 min',
        ),
        Divider(height: context.tokens.spacing.xxl),
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
        size: context.tokens.icons.md,
        color: Theme.of(context).colorScheme.primary,
      ),
      SizedBox(width: context.tokens.spacing.md),
      Expanded(
        child: Text(date, style: Theme.of(context).textTheme.titleSmall),
      ),
      Text(count, style: Theme.of(context).textTheme.bodyMedium),
      SizedBox(width: context.tokens.spacing.lg),
      SizedBox(
        width: context.tokens.spacing.huge,
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
      constraints: BoxConstraints(maxWidth: context.tokens.sizes.guideMaxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(review.title, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: context.tokens.spacing.xs),
          Text(review.instruction),
          SizedBox(height: context.tokens.spacing.lg),
          Row(
            children: [
              Icon(AppIcons.mockExam, size: context.tokens.icons.md),
              SizedBox(width: context.tokens.spacing.sm),
              Text('${review.duration} previstos'),
            ],
          ),
          SizedBox(height: context.tokens.spacing.md),
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

Future<void> _showReviewDialog(BuildContext context, _ReviewPreview review) => showDialog<void>(
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
  AppSnackbar.show(context, message: 'Os filtros serão conectados aos dados depois.');
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
