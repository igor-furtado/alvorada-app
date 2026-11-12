import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
import '../../../disciplinas/domain/models/disciplina.dart';
import '../../../disciplinas/domain/use_cases/disciplinas_use_cases.dart';
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
          'Disciplina adicionada ao Edital.',
          AppToastVariant.success,
        ),
        EditalEditorFeedback.topicoAdicionado => (
          'Tópico adicionado ao Edital.',
          AppToastVariant.success,
        ),
        EditalEditorFeedback.topicoRemovido => (
          'Tópico removido do Edital.',
          AppToastVariant.success,
        ),
        EditalEditorFeedback.violacaoRegra => (
          'O Edital não pôde ser atualizado com essa alteração.',
          AppToastVariant.error,
        ),
        EditalEditorFeedback.falhaTecnica => (
          'Não foi possível atualizar o Edital. Tente novamente.',
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
      title: 'Adicionar ao Edital',
      description: 'Vincule conteúdo existente no catálogo.',
      child: _conteudo(state),
    ),
  );

  Widget _conteudo(EditalEditorState state) {
    if (state.status case EditalEditorStatus.initial || EditalEditorStatus.loading) {
      return const AppSkeleton(height: 320, semanticLabel: 'Carregando catálogo');
    }
    if (state.status == EditalEditorStatus.failure) {
      return AppStateView(
        variant: AppStateVariant.error,
        actionLabel: 'Tentar novamente',
        onAction: () => context.read<EditalEditorBloc>().add(const EditalEditorRetried()),
      );
    }
    return AppTabs<_EditorTab>(
      initialValue: _EditorTab.disciplina,
      expanded: true,
      items: [
        AppTabItem(
          value: _EditorTab.disciplina,
          label: 'Disciplina',
          content: _disciplinas(state),
        ),
        AppTabItem(
          value: _EditorTab.topico,
          label: 'Tópico',
          content: _topicos(state),
        ),
      ],
    );
  }

  Widget _disciplinas(EditalEditorState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _nota('Vincule ao Edital uma Disciplina já existente no catálogo compartilhado.'),
        SizedBox(height: context.tokens.spacing.lg),
        AppField(
          label: 'Buscar Disciplina',
          control: AppSearchField(
            placeholder: 'Ex.: Direito Penal',
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
      subtitle: '${comuns.length} Tópicos no catálogo',
      trailing: AppButton(
        label: completa ? 'Adicionada' : 'Adicionar',
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
        _nota('Escolha uma Disciplina do Edital e vincule ou remova um Tópico existente.'),
        SizedBox(height: context.tokens.spacing.lg),
        AppField(
          label: 'Disciplina',
          control: AppSelect<String>(
            value: selecionada?.id,
            placeholder: 'Selecione uma Disciplina',
            options: [
              for (final disciplina in vinculadas) AppSelectOption(value: disciplina.id, label: disciplina.name),
            ],
            onChanged: vinculadas.isEmpty
                ? null
                : (value) => context.read<EditalEditorBloc>().add(EditalEditorDisciplinaSelected(value)),
          ),
        ),
        SizedBox(height: context.tokens.spacing.lg),
        AppField(
          label: 'Buscar Tópico',
          control: AppSearchField(
            placeholder: 'Ex.: Obrigação tributária',
            enabled: selecionada != null,
            onChanged: (value) => context.read<EditalEditorBloc>().add(EditalEditorTopicoSearched(value)),
          ),
        ),
        SizedBox(height: context.tokens.spacing.lg),
        if (selecionada == null)
          const AppStateView(
            variant: AppStateVariant.empty,
            title: 'Nenhuma Disciplina no Edital',
            message: 'Adicione uma Disciplina para vincular Tópicos individualmente.',
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
      subtitle: 'Catálogo compartilhado',
      trailing: AppButton(
        label: vinculado ? 'Remover do Edital' : 'Adicionar',
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
