import 'package:flutter/material.dart';

import '../../../core/presentation/app_shell.dart';
import '../../../core/theme/app_theme.dart';

class HorizonsPage extends StatelessWidget {
  const HorizonsPage({super.key});

  static const _horizons = [
    _HorizonPreview(
      title: 'Analista Legislativo',
      area: 'Área administrativa',
      examDate: '27 de janeiro',
      daysUntilExam: 82,
      phase: 'Consolidação',
      progress: .34,
      disciplines: 10,
      topics: 86,
      weeklyHours: 10,
      isPrimary: true,
    ),
    _HorizonPreview(
      title: 'Auditor de Controle',
      area: 'Controle e gestão pública',
      examDate: '19 de abril',
      daysUntilExam: 164,
      phase: 'Fundação',
      progress: .18,
      disciplines: 12,
      topics: 104,
      weeklyHours: 4,
    ),
  ];

  @override
  Widget build(BuildContext context) => AppShell(
    section: AppSection.horizons,
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
                  child: _HorizonsContent(
                    horizons: _horizons,
                    desktop: desktop,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _HorizonsContent extends StatelessWidget {
  const _HorizonsContent({required this.horizons, required this.desktop});

  final List<_HorizonPreview> horizons;
  final bool desktop;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (!desktop) ...[
        const AppBrandLogo(width: 178),
        const SizedBox(height: 28),
      ],
      _Header(onAdd: () => _showNewHorizonDialog(context)),
      const SizedBox(height: 28),
      const _OverviewStrip(),
      const SizedBox(height: 24),
      LayoutBuilder(
        builder: (context, constraints) {
          final twoColumns = constraints.maxWidth >= 820;
          final list = Column(
            children: [
              for (var index = 0; index < horizons.length; index++) ...[
                _HorizonCard(horizon: horizons[index]),
                if (index < horizons.length - 1) const SizedBox(height: 16),
              ],
            ],
          );
          const priority = _PriorityCard();

          if (!twoColumns) {
            return Column(
              children: [list, const SizedBox(height: 20), priority],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: list),
              const SizedBox(width: 20),
              const Expanded(flex: 4, child: priority),
            ],
          );
        },
      ),
      const SizedBox(height: 24),
      const _SharedTopicsCard(),
    ],
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 620;
      final title = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Horizontes', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 6),
          Text(
            'Seus concursos-alvo e a direção que cada Edital dá ao plano.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
      final button = FilledButton.icon(
        onPressed: onAdd,
        icon: const Icon(AppIcons.add, size: AppIcons.compact),
        label: const Text('Novo Horizonte'),
      );

      if (compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [title, const SizedBox(height: 20), button],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: title),
          const SizedBox(width: 24),
          button,
        ],
      );
    },
  );
}

class _OverviewStrip extends StatelessWidget {
  const _OverviewStrip();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Wrap(
      spacing: 28,
      runSpacing: 16,
      children: [
        _OverviewItem(
          icon: AppIcons.horizons,
          value: '2',
          label: 'Horizontes ativos',
        ),
        _OverviewItem(
          icon: AppIcons.bookText,
          value: '18',
          label: 'Tópicos compartilhados',
        ),
        _OverviewItem(
          icon: AppIcons.calendar,
          value: '14 h',
          label: 'Disponíveis por semana',
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
    width: 220,
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
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

class _HorizonCard extends StatelessWidget {
  const _HorizonCard({required this.horizon});

  final _HorizonPreview horizon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(
          color: horizon.isPrimary ? scheme.primary : scheme.outlineVariant,
          width: horizon.isPrimary ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (horizon.isPrimary) Container(width: 6, color: scheme.primary),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            horizon.isPrimary
                                ? AppIcons.horizonsActive
                                : AppIcons.horizons,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (horizon.isPrimary) ...[
                                const _PrimaryBadge(),
                                const SizedBox(height: 8),
                              ],
                              Text(
                                horizon.title,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                horizon.area,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Mais opções',
                          onPressed: () => _showPreviewMessage(context),
                          icon: const Icon(Icons.more_horiz),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 18,
                      runSpacing: 12,
                      children: [
                        _MetaItem(
                          label: 'Prova',
                          value:
                              '${horizon.examDate} · ${horizon.daysUntilExam} dias',
                        ),
                        _MetaItem(label: 'Fase', value: horizon.phase),
                        _MetaItem(
                          label: 'Edital',
                          value:
                              '${horizon.disciplines} disciplinas · ${horizon.topics} tópicos',
                        ),
                        _MetaItem(
                          label: 'Esta semana',
                          value: '${horizon.weeklyHours} h por semana',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Cobertura do Edital',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium,
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${(horizon.progress * 100).round()}%',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: horizon.progress,
                                minHeight: 7,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        OutlinedButton(
                          onPressed: () => _showPreviewMessage(context),
                          child: const Text('Ver Edital'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryBadge extends StatelessWidget {
  const _PrimaryBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      'Horizonte principal',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 190,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 3),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}

class _PriorityCard extends StatelessWidget {
  const _PriorityCard();

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
          AppIcons.scales,
          size: AppIcons.prominent,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Como o plano decide',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Com 14 horas reais, o Plano protege primeiro o Horizonte principal e preserva as Revisões já programadas.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        const _PriorityStep(
          number: '1',
          title: 'Tópicos compartilhados',
          description: 'Um estudo conta para os dois Horizontes.',
        ),
        const _PriorityStep(
          number: '2',
          title: 'Peso combinado',
          description: 'Relevância do Edital e proximidade da prova.',
        ),
        const _PriorityStep(
          number: '3',
          title: 'Horizonte principal',
          description: 'Recebe prioridade quando as horas não bastam.',
          last: true,
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _showPreviewMessage(context),
          icon: const Icon(AppIcons.observation, size: 18),
          label: const Text('Entender a prioridade'),
        ),
      ],
    ),
  );
}

class _PriorityStep extends StatelessWidget {
  const _PriorityStep({
    required this.number,
    required this.title,
    required this.description,
    this.last = false,
  });

  final String number;
  final String title;
  final String description;
  final bool last;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                number,
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
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 3),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _SharedTopicsCard extends StatelessWidget {
  const _SharedTopicsCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondaryContainer,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(AppIcons.reviews, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Você não estuda o mesmo Tópico duas vezes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 5),
              Text(
                'Os 18 Tópicos presentes nos dois Editais têm um único ciclo. Leitura, questões e Revisões contam para ambos os Horizontes.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _NewHorizonDialog extends StatelessWidget {
  const _NewHorizonDialog();

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Novo Horizonte'),
    content: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dê direção ao estudo antes de montar seu Plano.'),
          SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              labelText: 'Concurso-alvo',
              hintText: 'Ex.: Analista Legislativo',
            ),
          ),
          SizedBox(height: 14),
          TextField(
            decoration: InputDecoration(
              labelText: 'Data da prova',
              hintText: 'Escolha uma data ou deixe em aberto',
            ),
          ),
          SizedBox(height: 12),
          Text('Sem data? O próximo passo será organizar o Edital.'),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () => Navigator.of(context).pop(true),
        child: const Text('Continuar'),
      ),
    ],
  );
}

Future<void> _showNewHorizonDialog(BuildContext context) async {
  final continueFlow = await showDialog<bool>(
    context: context,
    builder: (context) => const _NewHorizonDialog(),
  );
  if (continueFlow != true || !context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('A montagem do Edital entra na próxima etapa.'),
    ),
  );
}

void _showPreviewMessage(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(
        content: Text('O Edital será detalhado em uma das próximas telas.'),
      ),
    );
}

class _HorizonPreview {
  const _HorizonPreview({
    required this.title,
    required this.area,
    required this.examDate,
    required this.daysUntilExam,
    required this.phase,
    required this.progress,
    required this.disciplines,
    required this.topics,
    required this.weeklyHours,
    this.isPrimary = false,
  });

  final String title;
  final String area;
  final String examDate;
  final int daysUntilExam;
  final String phase;
  final double progress;
  final int disciplines;
  final int topics;
  final int weeklyHours;
  final bool isPrimary;
}
