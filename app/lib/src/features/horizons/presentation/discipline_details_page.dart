import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/presentation/app_shell.dart';
import '../../../core/theme/app_theme.dart';
import 'horizon_view_data.dart';

class DisciplineDetailsArguments {
  const DisciplineDetailsArguments({
    required this.horizon,
    required this.discipline,
  });

  final HorizonViewData horizon;
  final HorizonDisciplineProgress discipline;
}

class DisciplineDetailsPage extends StatefulWidget {
  const DisciplineDetailsPage({
    required this.horizonId,
    required this.disciplineName,
    this.arguments,
    super.key,
  });

  final String horizonId;
  final String disciplineName;
  final DisciplineDetailsArguments? arguments;

  @override
  State<DisciplineDetailsPage> createState() => _DisciplineDetailsPageState();
}

class _DisciplineDetailsPageState extends State<DisciplineDetailsPage> {
  late final HorizonViewData? _horizon =
      widget.arguments?.horizon ?? demoHorizonById(widget.horizonId);
  late final HorizonDisciplineProgress? _discipline =
      widget.arguments?.discipline ??
      _findDiscipline(_horizon, widget.disciplineName);
  late final TextEditingController _nameController = TextEditingController(
    text: _discipline?.name ?? '',
  );
  late final TextEditingController _weightController = TextEditingController(
    text: _discipline?.weight.toString() ?? '',
  );
  late final List<_TopicState> _topics = _buildTopics(
    _discipline?.name ?? widget.disciplineName,
  );

  int get _totalUnits =>
      _topics.fold(0, (total, topic) => total + 1 + topic.subtopics.length);

  int get _completedUnits => _topics.fold(
    0,
    (total, topic) =>
        total +
        (topic.completed ? 1 : 0) +
        topic.subtopics.where((item) => item.completed).length,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizon = _horizon;
    final discipline = _discipline;
    return AppShell(
      section: AppSection.horizons,
      builder: (context, desktop) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            desktop ? 40 : 20,
            20,
            desktop ? 40 : 20,
            48,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!desktop) ...[
                    const AppBrandLogo(width: 178),
                    const SizedBox(height: 24),
                  ],
                  AppBreadcrumbs(
                    items: [
                      const AppBreadcrumbItem(
                        label: 'Horizontes',
                        route: '/horizontes',
                      ),
                      AppBreadcrumbItem(
                        label: horizon?.shortName ?? 'Horizonte',
                        route: horizon == null
                            ? null
                            : '/horizontes/${Uri.encodeComponent(horizon.id)}',
                      ),
                      AppBreadcrumbItem(
                        label: _nameController.text.isEmpty
                            ? 'Disciplina'
                            : _nameController.text,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (horizon == null || discipline == null)
                    const _NotFound()
                  else ...[
                    _EditableDisciplineHeader(
                      horizon: horizon,
                      discipline: discipline,
                      nameController: _nameController,
                      weightController: _weightController,
                      onNameChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 22),
                    _VerticalizedTopics(
                      topics: _topics,
                      completed: _completedUnits,
                      total: _totalUnits,
                      onChanged: () => setState(() {}),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditableDisciplineHeader extends StatelessWidget {
  const _EditableDisciplineHeader({
    required this.horizon,
    required this.discipline,
    required this.nameController,
    required this.weightController,
    required this.onNameChanged,
  });

  final HorizonViewData horizon;
  final HorizonDisciplineProgress discipline;
  final TextEditingController nameController;
  final TextEditingController weightController;
  final ValueChanged<String> onNameChanged;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: _cardDecoration(context),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final identity = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                AppIcons.bookText,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    key: const ValueKey('discipline-name'),
                    controller: nameController,
                    onChanged: onNameChanged,
                    style: Theme.of(context).textTheme.headlineSmall,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Disciplina',
                      suffixIcon: Icon(Icons.edit_outlined, size: 18),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${horizon.shortName} · ${horizon.role}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        final metrics = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: TextField(
                key: const ValueKey('discipline-weight'),
                controller: weightController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Peso no Edital',
                  suffixIcon: Icon(Icons.edit_outlined, size: 17),
                ),
              ),
            ),
            const SizedBox(width: 24),
            _Metric(
              label: 'Avanço no Edital',
              value: '${(discipline.progress * 100).round()}%',
            ),
            const SizedBox(width: 24),
            _Metric(
              label: 'Desempenho',
              value: '${(discipline.performance * 100).round()}%',
            ),
          ],
        );
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [identity, const SizedBox(height: 20), metrics],
          );
        }
        return Row(
          children: [
            Expanded(flex: 6, child: identity),
            const SizedBox(width: 28),
            metrics,
          ],
        );
      },
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(height: 8),
      Text(value, style: Theme.of(context).textTheme.titleLarge),
    ],
  );
}

class _VerticalizedTopics extends StatelessWidget {
  const _VerticalizedTopics({
    required this.topics,
    required this.completed,
    required this.total,
    required this.onChanged,
  });

  final List<_TopicState> topics;
  final int completed;
  final int total;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _cardDecoration(context),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 1080,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'EDITAL VERTICALIZADO',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    Text(
                      '$completed de $total concluídos',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(width: 18),
                    SizedBox(
                      width: 110,
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${(progress * 100).round()}%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const _TopicsHeader(),
                for (var index = 0; index < topics.length; index++) ...[
                  _TopicRow(
                    topic: topics[index],
                    position: index + 1,
                    onChanged: onChanged,
                  ),
                  if (topics[index].expanded)
                    for (
                      var subIndex = 0;
                      subIndex < topics[index].subtopics.length;
                      subIndex++
                    )
                      _SubtopicRow(
                        subtopic: topics[index].subtopics[subIndex],
                        position: '${index + 1}.${subIndex + 1}',
                        onChanged: onChanged,
                      ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopicsHeader extends StatelessWidget {
  const _TopicsHeader();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Row(
      children: [
        Expanded(flex: 58, child: _HeaderLabel('Tópico')),
        Expanded(flex: 12, child: _HeaderLabel('Questões')),
        Expanded(flex: 14, child: _HeaderLabel('Último estudo')),
        Expanded(flex: 9, child: _HeaderLabel('Estudo')),
        Expanded(flex: 9, child: _HeaderLabel('Material')),
      ],
    ),
  );
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({
    required this.topic,
    required this.position,
    required this.onChanged,
  });

  final _TopicState topic;
  final int position;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: topic.completed
          ? Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: .42)
          : Colors.transparent,
      border: Border(
        bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
    child: Row(
      children: [
        Expanded(
          flex: 58,
          child: Row(
            children: [
              SizedBox(
                width: 34,
                child: topic.subtopics.isEmpty
                    ? null
                    : IconButton(
                        tooltip: topic.expanded
                            ? 'Recolher Subtópicos'
                            : 'Mostrar Subtópicos',
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          topic.expanded = !topic.expanded;
                          onChanged();
                        },
                        icon: Icon(
                          topic.expanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_right,
                        ),
                      ),
              ),
              Checkbox(
                value: topic.completed,
                onChanged: (value) {
                  topic.completed = value ?? false;
                  onChanged();
                },
              ),
              SizedBox(
                width: 42,
                child: Text(
                  '$position',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Expanded(
                child: topic.isRequired
                    ? Row(
                        children: [
                          const Icon(AppIcons.lockedTopic, size: 17),
                          const SizedBox(width: 8),
                          Text(
                            topic.title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      )
                    : TextFormField(
                        key: ValueKey('topic-$position'),
                        initialValue: topic.title,
                        onChanged: (value) => topic.title = value,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: UnderlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 8,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
        const Expanded(flex: 12, child: _EmptyCell()),
        const Expanded(flex: 14, child: _EmptyCell()),
        const Expanded(flex: 9, child: _EmptyCell()),
        const Expanded(flex: 9, child: _EmptyCell()),
      ],
    ),
  );
}

class _SubtopicRow extends StatelessWidget {
  const _SubtopicRow({
    required this.subtopic,
    required this.position,
    required this.onChanged,
  });

  final _SubtopicState subtopic;
  final String position;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: subtopic.completed
          ? Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: .28)
          : Colors.transparent,
      border: Border(
        bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    child: Row(
      children: [
        Expanded(
          flex: 58,
          child: Row(
            children: [
              const SizedBox(width: 42),
              Checkbox(
                value: subtopic.completed,
                onChanged: (value) {
                  subtopic.completed = value ?? false;
                  onChanged();
                },
              ),
              SizedBox(
                width: 62,
                child: Text(
                  position,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  key: ValueKey('subtopic-$position'),
                  initialValue: subtopic.title,
                  onChanged: (value) => subtopic.title = value,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: UnderlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Expanded(flex: 12, child: _EmptyCell()),
        const Expanded(flex: 14, child: _EmptyCell()),
        const Expanded(flex: 9, child: _EmptyCell()),
        const Expanded(flex: 9, child: _EmptyCell()),
      ],
    ),
  );
}

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) =>
      Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall);
}

class _EmptyCell extends StatelessWidget {
  const _EmptyCell();

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      '—',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class _TopicState {
  _TopicState({
    required this.title,
    required this.subtopics,
    this.expanded = false,
    this.isRequired = false,
  });

  String title;
  final List<_SubtopicState> subtopics;
  bool completed = false;
  bool expanded;
  final bool isRequired;
}

class _SubtopicState {
  _SubtopicState({required this.title});

  String title;
  bool completed = false;
}

HorizonDisciplineProgress? _findDiscipline(
  HorizonViewData? horizon,
  String name,
) {
  if (horizon == null) return null;
  for (final discipline in horizon.disciplines) {
    if (discipline.name == name) return discipline;
  }
  return null;
}

List<_TopicState> _buildTopics(String discipline) {
  final raw = switch (discipline) {
    'Língua Portuguesa' => const [
      (
        'Compreensão e interpretação de textos',
        [
          'Identificação do tema e da finalidade do texto',
          'Informações explícitas e implícitas',
          'Inferência, pressupostos e subentendidos',
        ],
      ),
      (
        'Tipologia e gêneros textuais',
        [
          'Narração, descrição e dissertação',
          'Gêneros oficiais, jornalísticos e argumentativos',
        ],
      ),
      (
        'Morfologia',
        [
          'Classes de palavras e seus empregos',
          'Formação e estrutura das palavras',
          'Flexões nominais e verbais',
        ],
      ),
      (
        'Sintaxe da oração e do período',
        [
          'Termos essenciais, integrantes e acessórios',
          'Coordenação e subordinação',
          'Concordância e regência',
        ],
      ),
      (
        'Pontuação e crase',
        [
          'Emprego dos sinais de pontuação',
          'Uso do acento indicativo de crase',
        ],
      ),
    ],
    'Direito Constitucional' => const [
      ('Princípios fundamentais', ['Fundamentos', 'Objetivos fundamentais']),
      (
        'Direitos e garantias fundamentais',
        ['Direitos individuais e coletivos', 'Direitos sociais'],
      ),
      (
        'Organização do Estado',
        ['União, Estados e Municípios', 'Administração Pública'],
      ),
      (
        'Controle de constitucionalidade',
        ['Controle difuso', 'Controle concentrado'],
      ),
    ],
    _ => [
      (
        'Fundamentos de $discipline',
        ['Conceitos essenciais', 'Princípios e aplicações'],
      ),
      (
        'Normas e procedimentos',
        ['Regras gerais', 'Exceções e casos práticos'],
      ),
      (
        'Questões aplicadas',
        ['Padrões recorrentes da banca', 'Casos e exercícios'],
      ),
    ],
  };

  return [
    for (var index = 0; index < raw.length; index++)
      _TopicState(
        title: raw[index].$1,
        subtopics: [
          for (final title in raw[index].$2) _SubtopicState(title: title),
        ],
        expanded: index == 0,
      ),
    _TopicState(title: 'Revisão de Véspera', subtopics: [], isRequired: true),
  ];
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 64),
    child: Center(child: Text('Disciplina não encontrada')),
  );
}

BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
  color: Theme.of(context).colorScheme.surface,
  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
  borderRadius: BorderRadius.circular(12),
);
