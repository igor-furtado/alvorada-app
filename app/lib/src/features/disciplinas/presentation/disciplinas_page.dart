import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/content/app_messages.dart';
import '../../../core/presentation/app_shell.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/app_ui.dart';
import '../domain/models/disciplina.dart';
import '../domain/models/disciplina_input.dart';
import 'bloc/disciplinas_bloc.dart';
import 'bloc/disciplinas_event.dart';
import 'bloc/disciplinas_state.dart';

class DisciplinasPage extends StatefulWidget {
  const DisciplinasPage({super.key});

  @override
  State<DisciplinasPage> createState() => _DisciplinasPageState();
}

class _DisciplinasPageState extends State<DisciplinasPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener<DisciplinasBloc, DisciplinasState>(
    listenWhen: (previous, current) => previous.feedback != current.feedback && current.feedback != null,
    listener: (context, state) {
      final feedback = state.feedback;
      if (feedback == null) return;
      final (message, variant) = _feedbackPresentation(feedback);
      AppSnackbar.show(context, message: message, variant: variant);
    },
    child: AppPageTemplate(
      maxWidth: context.tokens.sizes.contestPage,
      builder: (context, desktop) => BlocBuilder<DisciplinasBloc, DisciplinasState>(
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!desktop) ...[
              AppBrandLogo(width: context.tokens.layout.brandWidth),
              SizedBox(height: context.tokens.spacing.xxl),
            ],
            _DisciplinasHeader(
              canInteract: state.status == DisciplinasStatus.success,
              isRefreshing: state.isRefreshing,
              isMutating: state.isMutating,
              onRefresh: () => context.read<DisciplinasBloc>().add(const RefreshDisciplinasRequested()),
              onAddDiscipline: () => _addDisciplina(context),
            ),
            SizedBox(height: context.tokens.spacing.xxl),
            if (state.status == DisciplinasStatus.loading)
              const _DisciplinasLoading()
            else if (state.status == DisciplinasStatus.failure)
              AppStateView(
                variant: AppStateVariant.error,
                actionLabel: AppMessages.tryAgain,
                onAction: () => context.read<DisciplinasBloc>().add(const LoadDisciplinasRequested()),
              )
            else ...[
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: context.tokens.layout.reading),
                child: AppSearchField(
                  controller: _searchController,
                  placeholder: AppMessages.searchContent,
                  onChanged: (value) => context.read<DisciplinasBloc>().add(SearchDisciplinasChanged(value)),
                  onClear: state.query.isEmpty
                      ? null
                      : () {
                          _searchController.clear();
                          context.read<DisciplinasBloc>().add(const SearchDisciplinasChanged(''));
                        },
                ),
              ),
              SizedBox(height: context.tokens.spacing.xl),
              if (state.disciplinasVisiveis.isEmpty)
                _EmptyDisciplinas(
                  hasQuery: state.query.trim().isNotEmpty,
                  onAddDiscipline: () => _addDisciplina(context),
                )
              else
                for (final disciplina in state.disciplinasVisiveis) ...[
                  _DisciplinaCard(
                    disciplina: disciplina,
                    expandedTopicIds: state.expandedTopicIds,
                    onToggle: (topico) => context.read<DisciplinasBloc>().add(ToggleTopicoRequested(topico.id)),
                    onAddTopico: () => _addTopico(context, disciplina),
                    onRenameDisciplina: () => _renameDisciplina(context, disciplina),
                    onDeleteDisciplina: () => _deleteDisciplina(context, disciplina),
                    onRenameTopico: (topico) => _renameTopico(context, topico),
                    onDeleteTopico: (topico) => _deleteTopico(context, topico),
                    onAddSubtopico: (topico) => _addSubtopico(context, topico),
                    onRenameSubtopico: (subtopico) => _renameSubtopico(context, subtopico),
                    onDeleteSubtopico: (subtopico) => _deleteSubtopico(context, subtopico),
                  ),
                  SizedBox(height: context.tokens.spacing.lg),
                ],
            ],
          ],
        ),
      ),
    ),
  );

  Future<String?> _requestName(BuildContext context, {required String title, String? initialValue}) =>
      showDialog<String>(
        context: context,
        builder: (_) => _NameDialog(title: title, initialValue: initialValue),
      );

  Future<void> _addDisciplina(BuildContext context) async {
    final name = await _requestName(context, title: AppMessages.addDiscipline);
    if (name == null || !context.mounted) return;
    context.read<DisciplinasBloc>().add(CreateDisciplinaRequested(CreateDisciplinaInput(name: name)));
  }

  Future<void> _renameDisciplina(BuildContext context, Disciplina disciplina) async {
    final name = await _requestName(
      context,
      title: AppMessages.editDiscipline,
      initialValue: disciplina.name,
    );
    if (name == null || !context.mounted) return;
    context.read<DisciplinasBloc>().add(
      UpdateDisciplinaRequested(
        disciplineId: disciplina.id,
        input: UpdateDisciplinaInput(name: name),
      ),
    );
  }

  Future<void> _addTopico(BuildContext context, Disciplina disciplina) async {
    final name = await _requestName(context, title: AppMessages.addTopic);
    if (name == null || !context.mounted) return;
    context.read<DisciplinasBloc>().add(CreateTopicoRequested(disciplineId: disciplina.id, name: name));
  }

  Future<void> _renameTopico(BuildContext context, Topico topico) async {
    final name = await _requestName(context, title: AppMessages.editTopic, initialValue: topico.name);
    if (name == null || !context.mounted) return;
    context.read<DisciplinasBloc>().add(UpdateTopicoRequested(topicId: topico.id, name: name));
  }

  Future<void> _addSubtopico(BuildContext context, Topico topico) async {
    final name = await _requestName(context, title: AppMessages.addSubtopic);
    if (name == null || !context.mounted) return;
    context.read<DisciplinasBloc>().add(CreateSubtopicoRequested(topicId: topico.id, name: name));
  }

  Future<void> _renameSubtopico(BuildContext context, Subtopico subtopico) async {
    final name = await _requestName(context, title: AppMessages.editSubtopic, initialValue: subtopico.name);
    if (name == null || !context.mounted) return;
    context.read<DisciplinasBloc>().add(UpdateSubtopicoRequested(subtopicId: subtopico.id, name: name));
  }

  Future<void> _deleteDisciplina(BuildContext context, Disciplina disciplina) async {
    final confirmed = await _confirmDelete(
      context,
      title: AppMessages.deleteDisciplineQuestion,
      message: AppMessages.disciplineDeletedImpact(disciplina.name),
    );
    if (confirmed && context.mounted) {
      context.read<DisciplinasBloc>().add(DeleteDisciplinaRequested(disciplina.id));
    }
  }

  Future<void> _deleteTopico(BuildContext context, Topico topico) async {
    final confirmed = await _confirmDelete(
      context,
      title: AppMessages.deleteTopicQuestion,
      message: AppMessages.topicDeletedImpact(topico.name),
    );
    if (confirmed && context.mounted) {
      context.read<DisciplinasBloc>().add(DeleteTopicoRequested(topico.id));
    }
  }

  Future<void> _deleteSubtopico(BuildContext context, Subtopico subtopico) async {
    final confirmed = await _confirmDelete(
      context,
      title: AppMessages.deleteSubtopicQuestion,
      message: AppMessages.subtopicDeletedImpact(subtopico.name),
    );
    if (confirmed && context.mounted) {
      context.read<DisciplinasBloc>().add(DeleteSubtopicoRequested(subtopico.id));
    }
  }

  Future<bool> _confirmDelete(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
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

(String, AppSnackbarVariant) _feedbackPresentation(DisciplinasFeedback feedback) => switch (feedback) {
  DisciplinasFeedback.disciplinasAtualizadas => (AppMessages.disciplinesUpdated, AppSnackbarVariant.success),
  DisciplinasFeedback.disciplinaCriada => (AppMessages.disciplineCreated, AppSnackbarVariant.success),
  DisciplinasFeedback.disciplinaAtualizada => (AppMessages.disciplineUpdated, AppSnackbarVariant.success),
  DisciplinasFeedback.disciplinaExcluida => (AppMessages.disciplineDeleted, AppSnackbarVariant.success),
  DisciplinasFeedback.topicoCriado => (AppMessages.topicCreated, AppSnackbarVariant.success),
  DisciplinasFeedback.topicoAtualizado => (AppMessages.topicUpdated, AppSnackbarVariant.success),
  DisciplinasFeedback.topicoExcluido => (AppMessages.topicDeleted, AppSnackbarVariant.success),
  DisciplinasFeedback.subtopicoCriado => (AppMessages.subtopicCreated, AppSnackbarVariant.success),
  DisciplinasFeedback.subtopicoAtualizado => (AppMessages.subtopicUpdated, AppSnackbarVariant.success),
  DisciplinasFeedback.subtopicoExcluido => (AppMessages.subtopicDeleted, AppSnackbarVariant.success),
  DisciplinasFeedback.atualizacaoFalhou => (AppMessages.contentUpdateFailed, AppSnackbarVariant.error),
  DisciplinasFeedback.operacaoFalhou => (AppMessages.contentOperationFailed, AppSnackbarVariant.error),
};

class _DisciplinasHeader extends StatelessWidget {
  const _DisciplinasHeader({
    required this.canInteract,
    required this.isRefreshing,
    required this.isMutating,
    required this.onRefresh,
    required this.onAddDiscipline,
  });

  final bool canInteract;
  final bool isRefreshing;
  final bool isMutating;
  final VoidCallback onRefresh;
  final VoidCallback onAddDiscipline;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final heading = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppMessages.contentCatalog, style: Theme.of(context).textTheme.headlineLarge),
          SizedBox(height: context.tokens.spacing.xs),
          Text(
            AppMessages.contentCatalogSubtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
      final actions = Wrap(
        spacing: context.tokens.spacing.sm,
        runSpacing: context.tokens.spacing.sm,
        children: [
          AppButton(
            label: AppMessages.update,
            icon: AppIcons.reviews,
            variant: AppButtonVariant.outline,
            loading: isRefreshing,
            onPressed: !canInteract || isMutating ? null : onRefresh,
          ),
          AppButton(
            label: AppMessages.addDiscipline,
            icon: AppIcons.add,
            onPressed: !canInteract || isRefreshing || isMutating ? null : onAddDiscipline,
          ),
        ],
      );
      if (constraints.maxWidth < context.tokens.layout.toolbar) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            heading,
            SizedBox(height: context.tokens.spacing.xl),
            actions,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: heading),
          SizedBox(width: context.tokens.spacing.xl),
          actions,
        ],
      );
    },
  );
}

enum _DisciplinaAction { rename, delete }

enum _TopicoAction { rename, addSubtopic, delete }

enum _SubtopicoAction { rename, delete }

class _DisciplinaCard extends StatelessWidget {
  const _DisciplinaCard({
    required this.disciplina,
    required this.expandedTopicIds,
    required this.onToggle,
    required this.onAddTopico,
    required this.onRenameDisciplina,
    required this.onDeleteDisciplina,
    required this.onRenameTopico,
    required this.onDeleteTopico,
    required this.onAddSubtopico,
    required this.onRenameSubtopico,
    required this.onDeleteSubtopico,
  });

  final Disciplina disciplina;
  final Set<String> expandedTopicIds;
  final ValueChanged<Topico> onToggle;
  final VoidCallback onAddTopico;
  final VoidCallback onRenameDisciplina;
  final VoidCallback onDeleteDisciplina;
  final ValueChanged<Topico> onRenameTopico;
  final ValueChanged<Topico> onDeleteTopico;
  final ValueChanged<Topico> onAddSubtopico;
  final ValueChanged<Subtopico> onRenameSubtopico;
  final ValueChanged<Subtopico> onDeleteSubtopico;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        Padding(
          padding: EdgeInsets.all(context.tokens.spacing.xl),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final menu = AppMenuButton<_DisciplinaAction>(
                icon: AppIcons.settings,
                label: '${AppMessages.moreActions}: ${disciplina.name}',
                items: const [
                  AppMenuItem(value: _DisciplinaAction.rename, label: AppMessages.rename, icon: AppIcons.edit),
                  AppMenuItem(
                    value: _DisciplinaAction.delete,
                    label: AppMessages.delete,
                    icon: AppIcons.delete,
                    destructive: true,
                  ),
                ],
                onSelected: (action) => switch (action) {
                  _DisciplinaAction.rename => onRenameDisciplina(),
                  _DisciplinaAction.delete => onDeleteDisciplina(),
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
                        Text(disciplina.name, style: Theme.of(context).textTheme.titleMedium),
                        SizedBox(height: context.tokens.spacing.xxs),
                        Text(
                          '${disciplina.topics.length} Tópicos · ${disciplina.subtopicCount} Subtópicos',
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
              final addTopico = AppButton(
                label: AppMessages.addTopic,
                icon: AppIcons.add,
                variant: AppButtonVariant.text,
                size: AppButtonSize.sm,
                onPressed: onAddTopico,
              );
              if (constraints.maxWidth < context.tokens.layout.narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    identity,
                    SizedBox(height: context.tokens.spacing.md),
                    addTopico,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: identity),
                  addTopico,
                  menu,
                ],
              );
            },
          ),
        ),
        const AppDivider(),
        for (final topico in disciplina.topics)
          _TopicoTile(
            topico: topico,
            expanded: expandedTopicIds.contains(topico.id),
            onToggle: () => onToggle(topico),
            onRename: () => onRenameTopico(topico),
            onDelete: () => onDeleteTopico(topico),
            onAddSubtopico: () => onAddSubtopico(topico),
            onRenameSubtopico: onRenameSubtopico,
            onDeleteSubtopico: onDeleteSubtopico,
          ),
      ],
    ),
  );
}

class _TopicoTile extends StatelessWidget {
  const _TopicoTile({
    required this.topico,
    required this.expanded,
    required this.onToggle,
    required this.onRename,
    required this.onDelete,
    required this.onAddSubtopico,
    required this.onRenameSubtopico,
    required this.onDeleteSubtopico,
  });

  final Topico topico;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onAddSubtopico;
  final ValueChanged<Subtopico> onRenameSubtopico;
  final ValueChanged<Subtopico> onDeleteSubtopico;

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
              icon: expanded ? AppIcons.expandMore : AppIcons.expandNext,
              label: expanded ? 'Recolher Subtópicos' : 'Mostrar Subtópicos',
              selected: expanded,
              onPressed: topico.subtopics.isEmpty ? null : onToggle,
            ),
            SizedBox(width: context.tokens.spacing.sm),
            Expanded(child: Text(topico.name, style: Theme.of(context).textTheme.bodyLarge)),
            if (topico.mandatory)
              const AppBadge(label: AppMessages.mandatoryTopic, variant: AppBadgeVariant.info)
            else
              AppMenuButton<_TopicoAction>(
                icon: AppIcons.settings,
                label: '${AppMessages.moreActions}: ${topico.name}',
                items: const [
                  AppMenuItem(
                    value: _TopicoAction.addSubtopic,
                    label: AppMessages.addSubtopic,
                    icon: AppIcons.add,
                  ),
                  AppMenuItem(value: _TopicoAction.rename, label: AppMessages.rename, icon: AppIcons.edit),
                  AppMenuItem(
                    value: _TopicoAction.delete,
                    label: AppMessages.delete,
                    icon: AppIcons.delete,
                    destructive: true,
                  ),
                ],
                onSelected: (action) => switch (action) {
                  _TopicoAction.rename => onRename(),
                  _TopicoAction.addSubtopic => onAddSubtopico(),
                  _TopicoAction.delete => onDelete(),
                },
              ),
          ],
        ),
      ),
      if (expanded)
        for (final subtopico in topico.subtopics)
          _SubtopicoTile(
            subtopico: subtopico,
            onRename: () => onRenameSubtopico(subtopico),
            onDelete: () => onDeleteSubtopico(subtopico),
          ),
      const AppDivider(),
    ],
  );
}

class _SubtopicoTile extends StatelessWidget {
  const _SubtopicoTile({required this.subtopico, required this.onRename, required this.onDelete});

  final Subtopico subtopico;
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
        Expanded(child: Text(subtopico.name)),
        AppMenuButton<_SubtopicoAction>(
          icon: AppIcons.settings,
          label: '${AppMessages.moreActions}: ${subtopico.name}',
          items: const [
            AppMenuItem(value: _SubtopicoAction.rename, label: AppMessages.rename, icon: AppIcons.edit),
            AppMenuItem(
              value: _SubtopicoAction.delete,
              label: AppMessages.delete,
              icon: AppIcons.delete,
              destructive: true,
            ),
          ],
          onSelected: (action) => switch (action) {
            _SubtopicoAction.rename => onRename(),
            _SubtopicoAction.delete => onDelete(),
          },
        ),
      ],
    ),
  );
}

class _EmptyDisciplinas extends StatelessWidget {
  const _EmptyDisciplinas({required this.hasQuery, required this.onAddDiscipline});

  final bool hasQuery;
  final VoidCallback onAddDiscipline;

  @override
  Widget build(BuildContext context) => AppStateView(
    variant: AppStateVariant.empty,
    title: AppMessages.noContentFound,
    actionLabel: hasQuery ? null : AppMessages.addDiscipline,
    onAction: hasQuery ? null : onAddDiscipline,
  );
}

class _DisciplinasLoading extends StatelessWidget {
  const _DisciplinasLoading();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppSkeleton(
        height: context.tokens.layout.controlHeight,
        width: context.tokens.layout.reading,
        semanticLabel: AppMessages.loadingDisciplines,
      ),
      SizedBox(height: context.tokens.spacing.xl),
      AppSkeleton(height: context.tokens.sizes.overviewPanel),
      SizedBox(height: context.tokens.spacing.lg),
      AppSkeleton(height: context.tokens.sizes.overviewPanel),
    ],
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
  late final TextEditingController _controller = TextEditingController(text: widget.initialValue);

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
