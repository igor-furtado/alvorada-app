import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/content/app_messages.dart';
import '../../../core/presentation/app_shell.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_ui.dart';
import 'contest_view_data.dart';

class DisciplineDetailsArguments {
  const DisciplineDetailsArguments({
    required this.contest,
    required this.discipline,
  });

  final ContestViewData contest;
  final ContestDisciplineProgress discipline;
}

class DisciplineDetailsPage extends StatefulWidget {
  const DisciplineDetailsPage({
    required this.contestId,
    required this.disciplineName,
    this.arguments,
    super.key,
  });

  final String contestId;
  final String disciplineName;
  final DisciplineDetailsArguments? arguments;

  @override
  State<DisciplineDetailsPage> createState() => _DisciplineDetailsPageState();
}

class _DisciplineDetailsPageState extends State<DisciplineDetailsPage> {
  late final ContestViewData? _contest = widget.arguments?.contest ?? demoContestById(widget.contestId);
  late final ContestDisciplineProgress? _discipline =
      widget.arguments?.discipline ?? _findDiscipline(_contest, widget.disciplineName);
  late final TextEditingController _nameController = TextEditingController(
    text: _discipline?.name ?? '',
  );
  late final TextEditingController _weightController = TextEditingController(
    text: _discipline?.weight.toString() ?? '',
  );
  late final List<_TopicState> _topics = _buildTopics(
    _discipline?.name ?? widget.disciplineName,
  );

  int get _totalUnits => _topics.fold(0, (total, topic) => total + 1 + topic.subtopics.length);

  int get _completedUnits => _topics.fold(
    0,
    (total, topic) => total + (topic.completed ? 1 : 0) + topic.subtopics.where((item) => item.completed).length,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contest = _contest;
    final discipline = _discipline;
    return AppPageTemplate(
      maxWidth: context.tokens.sizes.disciplinePage,
      builder: (context, desktop) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!desktop) ...[
            AppBrandLogo(width: context.tokens.layout.brandWidth),
            SizedBox(height: context.tokens.spacing.xxl),
          ],
          AppBreadcrumbs(
            items: [
              const AppBreadcrumbItem(
                label: AppMessages.navigationContests,
                route: '/concursos',
              ),
              AppBreadcrumbItem(
                label: contest?.shortName ?? AppMessages.contest,
                route: contest == null ? null : '/concursos/${Uri.encodeComponent(contest.id)}',
              ),
              AppBreadcrumbItem(
                label: _nameController.text.isEmpty ? 'Disciplina' : _nameController.text,
              ),
            ],
          ),
          SizedBox(height: context.tokens.spacing.xl),
          if (contest == null || discipline == null)
            const _NotFound()
          else ...[
            _EditableDisciplineHeader(
              contest: contest,
              discipline: discipline,
              nameController: _nameController,
              weightController: _weightController,
              onNameChanged: (_) => setState(() {}),
            ),
            SizedBox(height: context.tokens.spacing.xxl),
            _VerticalizedTopics(
              topics: _topics,
              completed: _completedUnits,
              total: _totalUnits,
              onChanged: () => setState(() {}),
            ),
          ],
        ],
      ),
    );
  }
}

class _EditableDisciplineHeader extends StatelessWidget {
  const _EditableDisciplineHeader({
    required this.contest,
    required this.discipline,
    required this.nameController,
    required this.weightController,
    required this.onNameChanged,
  });

  final ContestViewData contest;
  final ContestDisciplineProgress discipline;
  final TextEditingController nameController;
  final TextEditingController weightController;
  final ValueChanged<String> onNameChanged;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(context.tokens.spacing.xxl),
    decoration: _cardDecoration(context),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < context.tokens.layout.medium;
        final identity = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: context.tokens.sizes.identityIcon,
              height: context.tokens.sizes.identityIcon,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: context.tokens.borders.lg,
              ),
              child: Icon(
                AppIcons.bookText,
                color: context.tokens.colors.actionForeground,
              ),
            ),
            SizedBox(width: context.tokens.spacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    key: const ValueKey('discipline-name'),
                    controller: nameController,
                    onChanged: onNameChanged,
                    style: Theme.of(context).textTheme.headlineSmall,
                    decoration: InputDecoration(
                      labelText: AppMessages.disciplineName,
                      suffixIcon: Icon(
                        AppIcons.edit,
                        size: context.tokens.icons.md,
                      ),
                    ),
                  ),
                  SizedBox(height: context.tokens.spacing.sm),
                  Text(
                    '${contest.shortName} · ${contest.role}',
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
              width: context.tokens.sizes.compactField,
              child: TextField(
                key: const ValueKey('discipline-weight'),
                controller: weightController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: AppMessages.disciplineWeight,
                  suffixIcon: Icon(
                    AppIcons.edit,
                    size: context.tokens.icons.md,
                  ),
                ),
              ),
            ),
            SizedBox(width: context.tokens.spacing.xxl),
            _Metric(
              label: 'Avanço no Edital',
              value: '${(discipline.progress * 100).round()}%',
            ),
            SizedBox(width: context.tokens.spacing.xxl),
            _Metric(
              label: 'Desempenho',
              value: '${(discipline.performance * 100).round()}%',
            ),
          ],
        );
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              identity,
              SizedBox(height: context.tokens.spacing.xl),
              metrics,
            ],
          );
        }
        return Row(
          children: [
            Expanded(flex: 6, child: identity),
            SizedBox(width: context.tokens.spacing.xxxl),
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
      SizedBox(height: context.tokens.spacing.sm),
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
          width: context.tokens.sizes.disciplineTable,
          child: Padding(
            padding: EdgeInsets.all(context.tokens.spacing.xl),
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
                    SizedBox(width: context.tokens.spacing.xl),
                    SizedBox(
                      width: context.tokens.sizes.progressColumn,
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: context.tokens.sizes.progressIndicatorRegular,
                      ),
                    ),
                    SizedBox(width: context.tokens.spacing.md),
                    Text(
                      '${(progress * 100).round()}%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                SizedBox(height: context.tokens.spacing.xl),
                const _TopicsHeader(),
                for (var index = 0; index < topics.length; index++) ...[
                  _TopicRow(
                    topic: topics[index],
                    position: index + 1,
                    onChanged: onChanged,
                  ),
                  if (topics[index].expanded)
                    for (var subIndex = 0; subIndex < topics[index].subtopics.length; subIndex++)
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
    padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.md, vertical: context.tokens.spacing.lg),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: context.tokens.borders.md,
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
          ? Theme.of(context).colorScheme.secondaryContainer.withValues(
              alpha: context.tokens.opacity.selection,
            )
          : context.tokens.colors.transparent,
      border: Border(
        bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    ),
    padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.sm, vertical: context.tokens.spacing.md),
    child: Row(
      children: [
        Expanded(
          flex: 58,
          child: Row(
            children: [
              SizedBox(
                width: context.tokens.sizes.topicCheckbox,
                child: topic.subtopics.isEmpty
                    ? null
                    : IconButton(
                        tooltip: topic.expanded ? 'Recolher Subtópicos' : 'Mostrar Subtópicos',
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          topic.expanded = !topic.expanded;
                          onChanged();
                        },
                        icon: Icon(
                          topic.expanded ? AppIcons.expandMore : AppIcons.expandNext,
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
                width: context.tokens.layout.topicSelectionIndent,
                child: Text(
                  '$position',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: context.tokens.colors.actionForeground,
                  ),
                ),
              ),
              Expanded(
                child: topic.isRequired
                    ? Row(
                        children: [
                          Icon(AppIcons.lockedTopic, size: context.tokens.icons.md),
                          SizedBox(width: context.tokens.spacing.sm),
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
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: const UnderlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: context.tokens.spacing.xs,
                            vertical: context.tokens.spacing.sm,
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
          ? Theme.of(context).colorScheme.secondaryContainer.withValues(
              alpha: context.tokens.opacity.selectionFaint,
            )
          : context.tokens.colors.transparent,
      border: Border(
        bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    ),
    padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.sm, vertical: context.tokens.spacing.sm),
    child: Row(
      children: [
        Expanded(
          flex: 58,
          child: Row(
            children: [
              SizedBox(width: context.tokens.layout.topicSelectionIndent),
              Checkbox(
                value: subtopic.completed,
                onChanged: (value) {
                  subtopic.completed = value ?? false;
                  onChanged();
                },
              ),
              SizedBox(
                width: context.tokens.sizes.iconContainerLg,
                child: Text(
                  position,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: context.tokens.colors.actionForeground,
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  key: ValueKey('subtopic-$position'),
                  initialValue: subtopic.title,
                  onChanged: (value) => subtopic.title = value,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: const UnderlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: context.tokens.spacing.xs,
                      vertical: context.tokens.spacing.sm,
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
  Widget build(BuildContext context) => Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall);
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

ContestDisciplineProgress? _findDiscipline(
  ContestViewData? contest,
  String name,
) {
  if (contest == null) return null;
  for (final discipline in contest.disciplines) {
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
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: context.tokens.spacing.giant),
    child: const Center(child: Text(AppMessages.disciplineNotFound)),
  );
}

BoxDecoration _cardDecoration(BuildContext context) => BoxDecoration(
  color: Theme.of(context).colorScheme.surface,
  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
  borderRadius: context.tokens.borders.lg,
);
