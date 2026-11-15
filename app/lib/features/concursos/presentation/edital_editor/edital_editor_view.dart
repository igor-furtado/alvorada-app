import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:estudos_app/features/disciplinas/domain/models/disciplina.dart';
import 'package:estudos_app/features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/concurso.dart';
import '../../domain/use_cases/concursos_use_cases.dart';
import 'edital_editor_bloc.dart';
import 'edital_editor_event.dart';
import 'edital_editor_state.dart';

class EditalEditorView extends StatelessWidget {
  const EditalEditorView({required this.concurso, super.key});

  final Concurso concurso;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => EditalEditorBloc(
      concurso: concurso,
      getDisciplinas: context.read<DisciplinasUseCases>().getDisciplinas,
      edital: context.read<ConcursosUseCases>().edital,
    )..add(const EditalEditorLoaded()),
    child: const _EditalEditorContent(),
  );
}

class _EditalEditorContent extends StatefulWidget {
  const _EditalEditorContent();

  @override
  State<_EditalEditorContent> createState() => _EditalEditorContentState();
}

class _EditalEditorContentState extends State<_EditalEditorContent> {
  @override
  Widget build(BuildContext context) => BlocConsumer<EditalEditorBloc, EditalEditorState>(
    listenWhen: (previous, current) => current.feedback != null && previous.feedback != current.feedback,
    listener: (context, state) {
      final feedback = state.feedback;
      if (feedback == null) return;
      final (message, variant) = switch (feedback) {
        EditalEditorFeedback.disciplinaAdicionada => (
          context.l10n.disciplineAddedToSyllabus,
          AppToastVariant.success,
        ),
        EditalEditorFeedback.topicoAdicionado => (
          context.l10n.topicAddedToSyllabus,
          AppToastVariant.success,
        ),
        EditalEditorFeedback.topicoRemovido => (
          context.l10n.topicRemovedFromSyllabus,
          AppToastVariant.success,
        ),
        EditalEditorFeedback.violacaoRegra => (
          context.l10n.syllabusRuleViolation,
          AppToastVariant.error,
        ),
        EditalEditorFeedback.falhaTecnica => (
          context.l10n.syllabusUpdateFailed,
          AppToastVariant.error,
        ),
      };
      AppToast.show(
        context,
        title: message,
        variant: variant,
      );
    },
    builder: (context, state) => AppDrawer(
      title: context.l10n.addToSyllabus,
      description: context.l10n.linkCatalogContent,
      child: _conteudo(state),
    ),
  );

  Widget _conteudo(EditalEditorState state) {
    if (state.status case EditalEditorStatus.initial || EditalEditorStatus.loading) {
      return AppSkeleton(height: 320, semanticLabel: context.l10n.loadingCatalog);
    }
    if (state.status == EditalEditorStatus.failure) {
      return AppStateView(
        variant: AppStateVariant.error,
        actionLabel: context.l10n.tryAgain,
        onAction: () => context.read<EditalEditorBloc>().add(const EditalEditorRetried()),
      );
    }
    return AppTabs<_EditorTab>(
      initialValue: _EditorTab.disciplina,
      expanded: true,
      items: [
        AppTabItem(
          value: _EditorTab.disciplina,
          label: context.l10n.discipline,
          content: _disciplinas(state),
        ),
        AppTabItem(
          value: _EditorTab.topico,
          label: context.l10n.topic,
          content: _topicos(state),
        ),
      ],
    );
  }

  Widget _disciplinas(EditalEditorState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _nota(context.l10n.linkDisciplineNote),
        SizedBox(height: context.tokens.spacing.lg),
        AppField(
          label: context.l10n.searchDiscipline,
          control: AppSearchField(
            placeholder: context.l10n.disciplineSearchExample,
            onChanged: (value) => context.read<EditalEditorBloc>().add(EditalEditorDisciplinaSearched(value)),
          ),
        ),
        SizedBox(height: context.tokens.spacing.lg),
        AppListItemGroup(
          children: [
            for (final disciplina in state.disciplinasFiltradas) _disciplinaItem(state, disciplina),
          ],
        ),
      ],
    );
  }

  Widget _disciplinaItem(EditalEditorState state, Disciplina disciplina) {
    final comuns = disciplina.topics.where((item) => !item.mandatory).toList(growable: false);
    final completa = comuns.isNotEmpty && comuns.every((item) => state.topicosVinculados.contains(item.id));
    return AppListItem(
      title: disciplina.name,
      subtitle: context.l10n.topicsInCatalog(comuns.length),
      trailing: AppButton(
        label: completa ? context.l10n.added : context.l10n.add,
        variant: AppButtonVariant.outline,
        loading: state.mutation?.matches(EditalEditorMutationType.disciplina, disciplina.id) ?? false,
        onPressed: comuns.isEmpty || completa || state.mutation != null
            ? null
            : () => context.read<EditalEditorBloc>().add(EditalEditorDisciplinaAdded(disciplina)),
      ),
    );
  }

  Widget _topicos(EditalEditorState state) {
    final vinculadas = state.catalogo.where(state.disciplinaEstaVinculada).toList(growable: false);
    final selecionada = vinculadas.cast<Disciplina?>().firstWhere(
      (item) => item?.id == state.disciplinaSelecionada,
      orElse: () => null,
    );
    final query = state.buscaTopico.trim().toLowerCase();
    final topicos = (selecionada?.topics ?? const <Topico>[])
        .where((item) => !item.mandatory && (query.isEmpty || item.name.toLowerCase().contains(query)))
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _nota(context.l10n.chooseDisciplineNote),
        SizedBox(height: context.tokens.spacing.lg),
        AppField(
          label: context.l10n.discipline,
          control: AppCombobox<String>(
            options: [for (final disciplina in vinculadas) disciplina.id],
            displayStringForOption: (id) => vinculadas.firstWhere((item) => item.id == id).name,
            value: selecionada?.id,
            placeholder: context.l10n.selectDiscipline,
            semanticLabel: context.l10n.discipline,
            showClear: true,
            disabled: vinculadas.isEmpty,
            onChanged: (value) => context.read<EditalEditorBloc>().add(EditalEditorDisciplinaSelected(value)),
          ),
        ),
        SizedBox(height: context.tokens.spacing.lg),
        AppField(
          label: context.l10n.searchTopic,
          control: AppSearchField(
            placeholder: context.l10n.topicSearchExample,
            enabled: selecionada != null,
            onChanged: (value) => context.read<EditalEditorBloc>().add(EditalEditorTopicoSearched(value)),
          ),
        ),
        SizedBox(height: context.tokens.spacing.lg),
        if (selecionada == null)
          AppStateView(
            variant: AppStateVariant.empty,
            title: context.l10n.noSyllabusDiscipline,
            message: context.l10n.noSyllabusDisciplineMessage,
          )
        else
          AppListItemGroup(
            children: [for (final topico in topicos) _topicoItem(state, topico)],
          ),
      ],
    );
  }

  Widget _topicoItem(EditalEditorState state, Topico topico) {
    final vinculado = state.topicosVinculados.contains(topico.id);
    return AppListItem(
      title: topico.name,
      subtitle: context.l10n.sharedCatalog,
      trailing: AppButton(
        label: vinculado ? context.l10n.removeFromSyllabus : context.l10n.add,
        variant: vinculado ? AppButtonVariant.text : AppButtonVariant.outline,
        loading: state.mutation?.matches(EditalEditorMutationType.topico, topico.id) ?? false,
        onPressed: state.mutation == null
            ? () => context.read<EditalEditorBloc>().add(EditalEditorTopicoToggled(topico))
            : null,
      ),
    );
  }

  Widget _nota(String texto) => Container(
    padding: EdgeInsets.all(context.tokens.spacing.md),
    decoration: BoxDecoration(
      color: context.tokens.colors.primaryContainer,
      borderRadius: context.tokens.borders.md,
    ),
    child: Text(
      texto,
      style: context.tokens.typography.bodyMedium.copyWith(
        color: context.tokens.colors.actionForeground,
      ),
    ),
  );
}

enum _EditorTab { disciplina, topico }
