import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/presentation/app_shell_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
import '../../domain/models/disciplina.dart';
import '../../domain/models/disciplina_input.dart';
import '../bloc/disciplinas_bloc.dart';
import '../bloc/disciplinas_event.dart';
import '../bloc/disciplinas_state.dart';
import '../widgets/disciplinas_catalog.dart';
import 'disciplinas_form.dart';

class DisciplinasPage extends StatefulWidget {
  const DisciplinasPage({super.key});

  @override
  State<DisciplinasPage> createState() => _DisciplinasPageState();
}

class _DisciplinasPageState extends State<DisciplinasPage> {
  final _shellOwner = Object();
  AppShellController? _shellController;
  String? _selectedDisciplineId;

  void _configureShellSearch(DisciplinasState state) {
    final controller = _shellController;
    if (controller == null) return;
    final canRefresh = state.status == DisciplinasStatus.success && !state.isRefreshing && !state.isMutating;
    controller.setSearch(
      _shellOwner,
      AppShellSearchConfig(
        placeholder: AppMessages.searchContent,
        actionIcon: AppIcons.reviews,
        actionLabel: AppMessages.update,
        onAction: canRefresh
            ? () => context.read<DisciplinasBloc>().add(
                const RefreshDisciplinasRequested(),
              )
            : null,
        onChanged: (value) {
          if (mounted) {
            context.read<DisciplinasBloc>().add(SearchDisciplinasChanged(value));
          }
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = AppShellScope.read(context);
    if (identical(controller, _shellController)) return;
    _shellController?.clearSearch(_shellOwner);
    _shellController = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _configureShellSearch(context.read<DisciplinasBloc>().state);
    });
  }

  @override
  void dispose() {
    _shellController?.clearSearch(_shellOwner);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<DisciplinasBloc, DisciplinasState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.isRefreshing != current.isRefreshing ||
            previous.isMutating != current.isMutating,
        listener: (context, state) => _configureShellSearch(state),
      ),
      BlocListener<DisciplinasBloc, DisciplinasState>(
        listenWhen: (previous, current) => previous.feedback != current.feedback && current.feedback != null,
        listener: (context, state) {
          final feedback = state.feedback;
          if (feedback == null) return;
          final (message, variant) = _feedbackPresentation(feedback);
          final synchronizationPending = feedback == DisciplinasFeedback.sincronizacaoPendente;
          AppToast.show(
            context,
            title: message,
            variant: variant,
            actionLabel: synchronizationPending ? AppMessages.update : null,
            onAction: synchronizationPending
                ? () => context.read<DisciplinasBloc>().add(
                    const RefreshDisciplinasRequested(),
                  )
                : null,
          );
        },
      ),
    ],
    child: SafeArea(
      top: false,
      child: ResponsiveBuilder(
        builder: (context, windowClass) {
          final pagePadding = windowClass.isExpanded ? context.tokens.spacing.page : context.tokens.spacing.xl;
          return Padding(
            padding: EdgeInsets.all(pagePadding),
            child: BlocBuilder<DisciplinasBloc, DisciplinasState>(
              builder: (context, state) {
                final visibleDisciplines = state.disciplinasVisiveis;
                final canMutate = state.status == DisciplinasStatus.success && !state.isRefreshing && !state.isMutating;
                final selectedDiscipline = visibleDisciplines.isEmpty
                    ? null
                    : visibleDisciplines.where((item) => item.id == _selectedDisciplineId).firstOrNull ??
                          visibleDisciplines.first;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _DisciplinasHeader(
                      canAdd: canMutate,
                      onAdd: () => _addDisciplina(context),
                    ),
                    SizedBox(height: context.tokens.spacing.xxl),
                    Expanded(
                      child: switch (state.status) {
                        DisciplinasStatus.loading => const AppSkeleton(
                          height: double.infinity,
                          semanticLabel: AppMessages.loadingDisciplines,
                        ),
                        DisciplinasStatus.failure => AppStateView(
                          variant: AppStateVariant.error,
                          actionLabel: AppMessages.tryAgain,
                          onAction: () => context.read<DisciplinasBloc>().add(
                            const LoadDisciplinasRequested(),
                          ),
                        ),
                        _ => DisciplinasCatalog(
                          query: state.query,
                          disciplinas: visibleDisciplines,
                          selectedDisciplina: selectedDiscipline,
                          expandedTopicIds: state.expandedTopicIds,
                          canMutate: canMutate,
                          actions: DisciplinasCatalogActions(
                            onAddDiscipline: () => _addDisciplina(context),
                            onSelectDisciplina: (disciplina) => setState(
                              () => _selectedDisciplineId = disciplina.id,
                            ),
                            onToggleTopico: (topico) => context.read<DisciplinasBloc>().add(
                              ToggleTopicoRequested(topico.id),
                            ),
                            onAddTopico: (disciplina) => _addTopico(context, disciplina),
                            onRenameDisciplina: (disciplina) => _renameDisciplina(context, disciplina),
                            onDeleteDisciplina: (disciplina) => _deleteDisciplina(context, disciplina),
                            onRenameTopico: (topico) => _renameTopico(context, topico),
                            onDeleteTopico: (topico) => _deleteTopico(context, topico),
                            onAddSubtopico: (topico) => _addSubtopico(context, topico),
                            onRenameSubtopico: (subtopico) => _renameSubtopico(context, subtopico),
                            onDeleteSubtopico: (subtopico) => _deleteSubtopico(context, subtopico),
                          ),
                        ),
                      },
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    ),
  );

  Future<String?> _requestName(BuildContext context, {required String title, String? initialValue}) =>
      showDialog<String>(
        context: context,
        builder: (_) => DisciplinasForm(
          title: title,
          actionLabel: initialValue == null ? AppMessages.add : AppMessages.saveChanges,
          initialValue: initialValue,
        ),
      );

  Future<void> _addDisciplina(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const DisciplinasForm(
        title: AppMessages.newDiscipline,
        actionLabel: AppMessages.addDiscipline,
        description: AppMessages.newDisciplineDescription,
        label: AppMessages.disciplineName,
        placeholder: AppMessages.disciplineNameExample,
        helperText: AppMessages.disciplineNameHelp,
      ),
    );
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
      builder: (dialogContext) => AppAlertDialog(
        title: title,
        description: message,
        cancelLabel: AppMessages.cancel,
        onCancel: () => Navigator.pop(dialogContext, false),
        actionLabel: AppMessages.delete,
        onAction: () => Navigator.pop(dialogContext, true),
        destructive: true,
      ),
    );
    return result ?? false;
  }
}

class _DisciplinasHeader extends StatelessWidget {
  const _DisciplinasHeader({required this.canAdd, required this.onAdd});

  final bool canAdd;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final heading = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppMessages.contentCatalog,
            style: context.tokens.typography.headlineLarge,
          ),
          SizedBox(height: context.tokens.spacing.xs),
          Text(
            AppMessages.contentCatalogSubtitle,
            style: context.tokens.typography.bodyLarge.copyWith(
              color: context.tokens.colors.onSurfaceMuted,
            ),
          ),
        ],
      );
      final action = AppButton(
        key: const ValueKey('add-discipline'),
        label: AppMessages.newDiscipline,
        icon: AppIcons.add,
        onPressed: canAdd ? onAdd : null,
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
          SizedBox(width: context.tokens.spacing.xxl),
          action,
        ],
      );
    },
  );
}

(String, AppToastVariant) _feedbackPresentation(DisciplinasFeedback feedback) => switch (feedback) {
  DisciplinasFeedback.disciplinasAtualizadas => (AppMessages.disciplinesUpdated, AppToastVariant.success),
  DisciplinasFeedback.disciplinaCriada => (AppMessages.disciplineCreated, AppToastVariant.success),
  DisciplinasFeedback.disciplinaAtualizada => (AppMessages.disciplineUpdated, AppToastVariant.success),
  DisciplinasFeedback.disciplinaExcluida => (AppMessages.disciplineDeleted, AppToastVariant.success),
  DisciplinasFeedback.topicoCriado => (AppMessages.topicCreated, AppToastVariant.success),
  DisciplinasFeedback.topicoAtualizado => (AppMessages.topicUpdated, AppToastVariant.success),
  DisciplinasFeedback.topicoExcluido => (AppMessages.topicDeleted, AppToastVariant.success),
  DisciplinasFeedback.subtopicoCriado => (AppMessages.subtopicCreated, AppToastVariant.success),
  DisciplinasFeedback.subtopicoAtualizado => (AppMessages.subtopicUpdated, AppToastVariant.success),
  DisciplinasFeedback.subtopicoExcluido => (AppMessages.subtopicDeleted, AppToastVariant.success),
  DisciplinasFeedback.atualizacaoFalhou => (AppMessages.contentUpdateFailed, AppToastVariant.error),
  DisciplinasFeedback.sincronizacaoPendente => (
    AppMessages.contentSavedSyncPending,
    AppToastVariant.info,
  ),
  DisciplinasFeedback.operacaoFalhou => (AppMessages.contentOperationFailed, AppToastVariant.error),
};
