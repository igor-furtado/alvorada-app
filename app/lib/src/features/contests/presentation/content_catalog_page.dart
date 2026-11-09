import 'package:flutter/material.dart';

import '../../../core/content/app_messages.dart';
import '../../../core/presentation/app_shell.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_ui.dart';

class ContentCatalogPage extends StatefulWidget {
  const ContentCatalogPage({super.key});

  @override
  State<ContentCatalogPage> createState() => _ContentCatalogPageState();
}

class _ContentCatalogPageState extends State<ContentCatalogPage> {
  final _searchController = TextEditingController();
  final _disciplines = _demoCatalog();
  String _query = '';

  List<_CatalogDiscipline> get _visibleDisciplines {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _disciplines;
    return _disciplines.where((discipline) {
      if (discipline.name.toLowerCase().contains(query)) return true;
      return discipline.topics.any(
        (topic) =>
            topic.name.toLowerCase().contains(query) ||
            topic.subtopics.any((subtopic) => subtopic.toLowerCase().contains(query)),
      );
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppPageTemplate(
    maxWidth: context.tokens.sizes.contestPage,
    builder: (context, desktop) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!desktop) ...[
          AppBrandLogo(width: context.tokens.layout.brandWidth),
          SizedBox(height: context.tokens.spacing.xxl),
        ],
        _CatalogHeader(onAddDiscipline: _addDiscipline),
        SizedBox(height: context.tokens.spacing.xxl),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.tokens.layout.reading),
          child: AppSearchField(
            controller: _searchController,
            placeholder: AppMessages.searchContent,
            onChanged: (value) => setState(() => _query = value),
            onClear: _query.isEmpty
                ? null
                : () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
          ),
        ),
        SizedBox(height: context.tokens.spacing.xl),
        if (_visibleDisciplines.isEmpty)
          _EmptyCatalog(onAddDiscipline: _addDiscipline)
        else
          for (final discipline in _visibleDisciplines) ...[
            _DisciplineCard(
              discipline: discipline,
              onToggle: (topic) => setState(() => topic.expanded = !topic.expanded),
              onAddTopic: () => _addTopic(discipline),
              onRenameDiscipline: () => _renameDiscipline(discipline),
              onDeleteDiscipline: () => _deleteDiscipline(discipline),
              onRenameTopic: _renameTopic,
              onDeleteTopic: (topic) => _deleteTopic(discipline, topic),
              onAddSubtopic: _addSubtopic,
              onRenameSubtopic: _renameSubtopic,
              onDeleteSubtopic: _deleteSubtopic,
            ),
            SizedBox(height: context.tokens.spacing.lg),
          ],
      ],
    ),
  );

  Future<String?> _requestName({required String title, String? initialValue}) => showDialog<String>(
    context: context,
    builder: (_) => _NameDialog(title: title, initialValue: initialValue),
  );

  Future<void> _addDiscipline() async {
    final name = await _requestName(title: AppMessages.addDiscipline);
    if (name == null || !mounted) return;
    setState(() {
      _disciplines.add(
        _CatalogDiscipline(
          name: name,
          topics: [_CatalogTopic.mandatory()],
        ),
      );
    });
  }

  Future<void> _renameDiscipline(_CatalogDiscipline discipline) async {
    final name = await _requestName(
      title: AppMessages.editDiscipline,
      initialValue: discipline.name,
    );
    if (name == null || !mounted) return;
    setState(() => discipline.name = name);
  }

  Future<void> _addTopic(_CatalogDiscipline discipline) async {
    final name = await _requestName(title: AppMessages.addTopic);
    if (name == null || !mounted) return;
    setState(() {
      discipline.topics.insert(
        discipline.topics.length - 1,
        _CatalogTopic(name: name),
      );
    });
  }

  Future<void> _renameTopic(_CatalogTopic topic) async {
    final name = await _requestName(
      title: AppMessages.editTopic,
      initialValue: topic.name,
    );
    if (name == null || !mounted) return;
    setState(() => topic.name = name);
  }

  Future<void> _addSubtopic(_CatalogTopic topic) async {
    final name = await _requestName(title: AppMessages.addSubtopic);
    if (name == null || !mounted) return;
    setState(() {
      topic.subtopics.add(name);
      topic.expanded = true;
    });
  }

  Future<void> _renameSubtopic(_CatalogTopic topic, String subtopic) async {
    final name = await _requestName(
      title: AppMessages.editSubtopic,
      initialValue: subtopic,
    );
    if (name == null || !mounted) return;
    final index = topic.subtopics.indexOf(subtopic);
    if (index < 0) return;
    setState(() => topic.subtopics[index] = name);
  }

  Future<void> _deleteDiscipline(_CatalogDiscipline discipline) async {
    final confirmed = await _confirmDelete(
      title: AppMessages.deleteDisciplineQuestion,
      message: AppMessages.disciplineDeletedImpact(discipline.name),
    );
    if (confirmed && mounted) setState(() => _disciplines.remove(discipline));
  }

  Future<void> _deleteTopic(_CatalogDiscipline discipline, _CatalogTopic topic) async {
    final confirmed = await _confirmDelete(
      title: AppMessages.deleteTopicQuestion,
      message: AppMessages.topicDeletedImpact(topic.name),
    );
    if (confirmed && mounted) setState(() => discipline.topics.remove(topic));
  }

  Future<void> _deleteSubtopic(_CatalogTopic topic, String subtopic) async {
    final confirmed = await _confirmDelete(
      title: AppMessages.deleteSubtopicQuestion,
      message: AppMessages.subtopicDeletedImpact(subtopic),
    );
    if (confirmed && mounted) setState(() => topic.subtopics.remove(subtopic));
  }

  Future<bool> _confirmDelete({required String title, required String message}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppDialog(
        title: title,
        content: Text(message),
        secondaryLabel: AppMessages.cancel,
        onSecondary: () => Navigator.pop(dialogContext, false),
        primaryLabel: AppMessages.delete,
        onPrimary: () => Navigator.pop(dialogContext, true),
        destructive: true,
      ),
    );
    return result ?? false;
  }
}

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader({required this.onAddDiscipline});

  final VoidCallback onAddDiscipline;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final heading = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppMessages.contentCatalog,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: context.tokens.spacing.xs),
          Text(
            AppMessages.contentCatalogSubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
      final action = AppButton(
        label: AppMessages.addDiscipline,
        icon: AppIcons.add,
        onPressed: onAddDiscipline,
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
          SizedBox(width: context.tokens.spacing.xl),
          action,
        ],
      );
    },
  );
}

enum _DisciplineAction { rename, delete }

enum _TopicAction { rename, addSubtopic, delete }

enum _SubtopicAction { rename, delete }

class _DisciplineCard extends StatelessWidget {
  const _DisciplineCard({
    required this.discipline,
    required this.onToggle,
    required this.onAddTopic,
    required this.onRenameDiscipline,
    required this.onDeleteDiscipline,
    required this.onRenameTopic,
    required this.onDeleteTopic,
    required this.onAddSubtopic,
    required this.onRenameSubtopic,
    required this.onDeleteSubtopic,
  });

  final _CatalogDiscipline discipline;
  final ValueChanged<_CatalogTopic> onToggle;
  final VoidCallback onAddTopic;
  final VoidCallback onRenameDiscipline;
  final VoidCallback onDeleteDiscipline;
  final ValueChanged<_CatalogTopic> onRenameTopic;
  final ValueChanged<_CatalogTopic> onDeleteTopic;
  final ValueChanged<_CatalogTopic> onAddSubtopic;
  final void Function(_CatalogTopic topic, String subtopic) onRenameSubtopic;
  final void Function(_CatalogTopic topic, String subtopic) onDeleteSubtopic;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.all(context.tokens.spacing.xl),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final menu = AppMenuButton<_DisciplineAction>(
                icon: AppIcons.settings,
                label: '${AppMessages.moreActions}: ${discipline.name}',
                items: const [
                  AppMenuItem(
                    value: _DisciplineAction.rename,
                    label: AppMessages.rename,
                    icon: AppIcons.edit,
                  ),
                  AppMenuItem(
                    value: _DisciplineAction.delete,
                    label: AppMessages.delete,
                    icon: AppIcons.delete,
                    destructive: true,
                  ),
                ],
                onSelected: (action) => switch (action) {
                  _DisciplineAction.rename => onRenameDiscipline(),
                  _DisciplineAction.delete => onDeleteDiscipline(),
                },
              );
              final identity = Row(
                children: [
                  Container(
                    width: context.tokens.sizes.iconContainerMd,
                    height: context.tokens.sizes.iconContainerMd,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: context.tokens.borders.md,
                    ),
                    child: Icon(
                      AppIcons.bookText,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: context.tokens.icons.md,
                    ),
                  ),
                  SizedBox(width: context.tokens.spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          discipline.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: context.tokens.spacing.xxs),
                        Text(
                          '${discipline.topics.length} Tópicos · ${discipline.subtopicCount} Subtópicos',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (constraints.maxWidth < context.tokens.layout.narrow) menu,
                ],
              );
              final addTopic = AppButton(
                label: AppMessages.addTopic,
                icon: AppIcons.add,
                variant: AppButtonVariant.text,
                size: AppButtonSize.sm,
                onPressed: onAddTopic,
              );
              if (constraints.maxWidth < context.tokens.layout.narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    identity,
                    SizedBox(height: context.tokens.spacing.md),
                    addTopic,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: identity),
                  addTopic,
                  menu,
                ],
              );
            },
          ),
        ),
        const AppDivider(),
        for (final topic in discipline.topics)
          _TopicTile(
            topic: topic,
            onToggle: () => onToggle(topic),
            onRename: () => onRenameTopic(topic),
            onDelete: () => onDeleteTopic(topic),
            onAddSubtopic: () => onAddSubtopic(topic),
            onRenameSubtopic: (subtopic) => onRenameSubtopic(topic, subtopic),
            onDeleteSubtopic: (subtopic) => onDeleteSubtopic(topic, subtopic),
          ),
      ],
    ),
  );
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({
    required this.topic,
    required this.onToggle,
    required this.onRename,
    required this.onDelete,
    required this.onAddSubtopic,
    required this.onRenameSubtopic,
    required this.onDeleteSubtopic,
  });

  final _CatalogTopic topic;
  final VoidCallback onToggle;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onAddSubtopic;
  final ValueChanged<String> onRenameSubtopic;
  final ValueChanged<String> onDeleteSubtopic;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.tokens.spacing.xl,
          vertical: context.tokens.spacing.sm,
        ),
        child: Row(
          children: [
            AppAccessibleIconButton(
              icon: topic.expanded ? AppIcons.expandMore : AppIcons.expandNext,
              label: topic.expanded ? 'Recolher Subtópicos' : 'Mostrar Subtópicos',
              selected: topic.expanded,
              onPressed: topic.subtopics.isEmpty ? null : onToggle,
            ),
            SizedBox(width: context.tokens.spacing.sm),
            Expanded(
              child: Text(
                topic.name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            if (topic.mandatory)
              const AppBadge(
                label: AppMessages.mandatoryTopic,
                variant: AppBadgeVariant.info,
              )
            else
              AppMenuButton<_TopicAction>(
                icon: AppIcons.settings,
                label: '${AppMessages.moreActions}: ${topic.name}',
                items: const [
                  AppMenuItem(
                    value: _TopicAction.addSubtopic,
                    label: AppMessages.addSubtopic,
                    icon: AppIcons.add,
                  ),
                  AppMenuItem(
                    value: _TopicAction.rename,
                    label: AppMessages.rename,
                    icon: AppIcons.edit,
                  ),
                  AppMenuItem(
                    value: _TopicAction.delete,
                    label: AppMessages.delete,
                    icon: AppIcons.delete,
                    destructive: true,
                  ),
                ],
                onSelected: (action) => switch (action) {
                  _TopicAction.rename => onRename(),
                  _TopicAction.addSubtopic => onAddSubtopic(),
                  _TopicAction.delete => onDelete(),
                },
              ),
          ],
        ),
      ),
      if (topic.expanded)
        for (final subtopic in topic.subtopics)
          _SubtopicTile(
            name: subtopic,
            onRename: () => onRenameSubtopic(subtopic),
            onDelete: () => onDeleteSubtopic(subtopic),
          ),
      const AppDivider(),
    ],
  );
}

class _SubtopicTile extends StatelessWidget {
  const _SubtopicTile({
    required this.name,
    required this.onRename,
    required this.onDelete,
  });

  final String name;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      context.tokens.spacing.huge,
      context.tokens.spacing.xs,
      context.tokens.spacing.xl,
      context.tokens.spacing.xs,
    ),
    child: Row(
      children: [
        Icon(
          AppIcons.arrowRight,
          size: context.tokens.icons.sm,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: context.tokens.spacing.md),
        Expanded(child: Text(name)),
        AppMenuButton<_SubtopicAction>(
          icon: AppIcons.settings,
          label: '${AppMessages.moreActions}: $name',
          items: const [
            AppMenuItem(
              value: _SubtopicAction.rename,
              label: AppMessages.rename,
              icon: AppIcons.edit,
            ),
            AppMenuItem(
              value: _SubtopicAction.delete,
              label: AppMessages.delete,
              icon: AppIcons.delete,
              destructive: true,
            ),
          ],
          onSelected: (action) => switch (action) {
            _SubtopicAction.rename => onRename(),
            _SubtopicAction.delete => onDelete(),
          },
        ),
      ],
    ),
  );
}

class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog({required this.onAddDiscipline});

  final VoidCallback onAddDiscipline;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      children: [
        Text(
          AppMessages.noContentFound,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: context.tokens.spacing.lg),
        AppButton(
          label: AppMessages.addDiscipline,
          icon: AppIcons.add,
          onPressed: onAddDiscipline,
        ),
      ],
    ),
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, this.initialValue});

  final String title;
  final String? initialValue;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) => AppDialog(
    title: widget.title,
    content: Form(
      key: _formKey,
      child: AppFormField(
        label: AppMessages.name,
        controller: _controller,
        required: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        validator: (value) => value == null || value.trim().isEmpty ? AppMessages.requiredField : null,
      ),
    ),
    secondaryLabel: AppMessages.cancel,
    onSecondary: () => Navigator.pop(context),
    primaryLabel: widget.initialValue == null ? AppMessages.add : AppMessages.saveChanges,
    onPrimary: _submit,
  );
}

class _CatalogDiscipline {
  _CatalogDiscipline({required this.name, required this.topics});

  String name;
  final List<_CatalogTopic> topics;

  int get subtopicCount => topics.fold(
    0,
    (total, topic) => total + topic.subtopics.length,
  );
}

class _CatalogTopic {
  _CatalogTopic({required this.name, List<String>? subtopics}) : subtopics = subtopics ?? [];

  _CatalogTopic.mandatory() : name = 'Revisão de Véspera', subtopics = [], mandatory = true;

  String name;
  final List<String> subtopics;
  bool expanded = false;
  bool mandatory = false;
}

List<_CatalogDiscipline> _demoCatalog() => [
  _CatalogDiscipline(
    name: 'Língua Portuguesa',
    topics: [
      _CatalogTopic(
        name: 'Compreensão e interpretação de textos',
        subtopics: [
          'Tipologia e gêneros textuais',
          'Inferência e pressupostos',
          'Coesão e coerência',
        ],
      ),
      _CatalogTopic(
        name: 'Domínio da estrutura morfossintática',
        subtopics: ['Classes de palavras', 'Concordância', 'Regência'],
      ),
      _CatalogTopic.mandatory(),
    ],
  ),
  _CatalogDiscipline(
    name: 'Direito Constitucional',
    topics: [
      _CatalogTopic(
        name: 'Direitos e garantias fundamentais',
        subtopics: ['Direitos individuais e coletivos', 'Remédios constitucionais'],
      ),
      _CatalogTopic(name: 'Organização do Estado'),
      _CatalogTopic.mandatory(),
    ],
  ),
  _CatalogDiscipline(
    name: 'Direito Administrativo',
    topics: [
      _CatalogTopic(
        name: 'Atos administrativos',
        subtopics: ['Elementos', 'Atributos', 'Extinção'],
      ),
      _CatalogTopic(name: 'Agentes públicos'),
      _CatalogTopic.mandatory(),
    ],
  ),
];
