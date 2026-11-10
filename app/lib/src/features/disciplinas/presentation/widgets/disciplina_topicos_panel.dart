part of 'disciplinas_catalog.dart';

/// Organiza o painel de detalhe usando apenas componentes públicos da UI.
class _DisciplinaTopicosPanel extends StatelessWidget {
  const _DisciplinaTopicosPanel({
    required this.disciplina,
    required this.canMutate,
    required this.expandedTopicIds,
    required this.onToggle,
    required this.onAddTopico,
    required this.onRenameTopico,
    required this.onDeleteTopico,
    required this.onAddSubtopico,
    required this.onRenameSubtopico,
    required this.onDeleteSubtopico,
  });

  final Disciplina disciplina;
  final bool canMutate;
  final Set<String> expandedTopicIds;
  final ValueChanged<Topico> onToggle;
  final VoidCallback onAddTopico;
  final ValueChanged<Topico> onRenameTopico;
  final ValueChanged<Topico> onDeleteTopico;
  final ValueChanged<Topico> onAddSubtopico;
  final ValueChanged<Subtopico> onRenameSubtopico;
  final ValueChanged<Subtopico> onDeleteSubtopico;

  @override
  Widget build(BuildContext context) {
    final regularTopics = disciplina.topics.where((topico) => !topico.mandatory).toList(growable: false);
    final mandatoryTopics = disciplina.topics.where((topico) => topico.mandatory).toList(growable: false);

    return Padding(
      padding: EdgeInsets.all(context.tokens.spacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final title = Text(
                AppMessages.topics,
                style: context.tokens.typography.titleLarge,
              );
              final addButton = AppButton(
                label: AppMessages.addTopic,
                icon: AppIcons.add,
                variant: AppButtonVariant.outline,
                size: AppButtonSize.sm,
                onPressed: canMutate ? onAddTopico : null,
              );
              if (constraints.maxWidth < context.tokens.layout.narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    title,
                    SizedBox(height: context.tokens.spacing.sm),
                    Align(alignment: Alignment.centerRight, child: addButton),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: title),
                  SizedBox(width: context.tokens.spacing.lg),
                  addButton,
                ],
              );
            },
          ),
          SizedBox(height: context.tokens.spacing.md),
          const AppDivider(margin: EdgeInsets.zero),
          if (regularTopics.isNotEmpty)
            AppAccordion<String>(
              expandedValues: expandedTopicIds,
              onToggle: (id) => onToggle(
                regularTopics.firstWhere((topico) => topico.id == id),
              ),
              items: [
                for (final topico in regularTopics)
                  AppAccordionItem<String>(
                    value: topico.id,
                    title: AppLabel(topico.name, style: AppLabelStyle.control),
                    child: _topicContent(context, topico),
                  ),
              ],
            ),
          if (mandatoryTopics.isNotEmpty) ...[
            SizedBox(height: context.tokens.spacing.lg),
            AppListItemGroup(
              spacing: context.tokens.spacing.sm,
              children: [
                for (final topico in mandatoryTopics)
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const badge = AppBadge(
                          label: AppMessages.protected,
                          variant: AppBadgeVariant.secondary,
                        );
                        final compact = constraints.maxWidth < context.tokens.layout.narrow;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppListItem(
                              key: ValueKey('mandatory-topic-${topico.id}'),
                              title: topico.name,
                              subtitle: AppMessages.mandatoryTopic,
                              leadingIcon: AppIcons.lockedTopic,
                              trailing: compact ? null : badge,
                              size: AppListItemSize.sm,
                            ),
                            if (compact)
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  context.tokens.spacing.md,
                                  context.tokens.spacing.none,
                                  context.tokens.spacing.md,
                                  context.tokens.spacing.md,
                                ),
                                child: const Align(
                                  alignment: Alignment.centerRight,
                                  child: badge,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _topicContent(BuildContext context, Topico topico) => Padding(
    padding: EdgeInsets.only(left: context.tokens.spacing.lg),
    child: SizedBox(
      width: double.infinity,
      child: AppListItemGroup(
        spacing: context.tokens.spacing.xxs,
        children: [
          AppListItem(
            title: topico.subtopics.isEmpty ? AppMessages.noSubtopics : AppMessages.subtopics,
            leadingIcon: AppIcons.book,
            trailing: AppButtonGroup(
              children: [
                AppButton(
                  key: ValueKey('add-subtopic-${topico.id}'),
                  label: AppMessages.addSubtopic,
                  icon: AppIcons.add,
                  variant: AppButtonVariant.text,
                  size: AppButtonSize.sm,
                  onPressed: canMutate ? () => onAddSubtopico(topico) : null,
                ),
                AppMenuButton<_TopicoAction>(
                  icon: AppIcons.settings,
                  label: '${AppMessages.moreActions}: ${topico.name}',
                  items: const [
                    AppMenuItem(
                      value: _TopicoAction.rename,
                      label: AppMessages.rename,
                      icon: AppIcons.edit,
                    ),
                    AppMenuItem(
                      value: _TopicoAction.delete,
                      label: AppMessages.delete,
                      icon: AppIcons.delete,
                      destructive: true,
                    ),
                  ],
                  enabled: canMutate,
                  onSelected: (action) => switch (action) {
                    _TopicoAction.rename => onRenameTopico(topico),
                    _TopicoAction.delete => onDeleteTopico(topico),
                  },
                ),
              ],
            ),
            variant: AppListItemVariant.muted,
            size: AppListItemSize.xs,
          ),
          for (final subtopico in topico.subtopics)
            AppListItem(
              key: ValueKey('subtopic-${subtopico.id}'),
              title: subtopico.name,
              leadingIcon: AppIcons.arrowRight,
              trailing: AppMenuButton<_SubtopicoAction>(
                icon: AppIcons.settings,
                label: '${AppMessages.moreActions}: ${subtopico.name}',
                items: const [
                  AppMenuItem(
                    value: _SubtopicoAction.rename,
                    label: AppMessages.rename,
                    icon: AppIcons.edit,
                  ),
                  AppMenuItem(
                    value: _SubtopicoAction.delete,
                    label: AppMessages.delete,
                    icon: AppIcons.delete,
                    destructive: true,
                  ),
                ],
                enabled: canMutate,
                onSelected: (action) => switch (action) {
                  _SubtopicoAction.rename => onRenameSubtopico(subtopico),
                  _SubtopicoAction.delete => onDeleteSubtopico(subtopico),
                },
              ),
              size: AppListItemSize.sm,
            ),
        ],
      ),
    ),
  );
}
