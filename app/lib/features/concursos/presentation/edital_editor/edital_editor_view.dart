import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:estudos_app/features/disciplinas/domain/models/disciplina.dart';
import 'package:estudos_app/features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/models/concurso.dart';
import '../../domain/use_cases/concursos_use_cases.dart';
import 'edital_editor_bloc.dart';
import 'edital_editor_event.dart';
import 'edital_editor_state.dart';

const _editorWidth = 980.0;
const _desktopSplit = 720.0;
const _disciplineRailWidth = 310.0;

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
    child: _EditalEditorContent(
      institution: concurso.instituicao,
      role: concurso.cargo,
    ),
  );
}

class _EditalEditorContent extends StatelessWidget {
  const _EditalEditorContent({required this.institution, required this.role});

  final String institution;
  final String role;

  @override
  Widget build(BuildContext context) => BlocConsumer<EditalEditorBloc, EditalEditorState>(
    listenWhen: (previous, current) => current.feedback != null && previous.feedback != current.feedback,
    listener: (context, state) {
      switch (state.feedback) {
        case EditalEditorFeedback.editalSalvo:
          Navigator.of(context).pop(true);
        case EditalEditorFeedback.violacaoRegra:
          AppToast.show(
            context,
            title: context.l10n.syllabusRuleViolation,
            variant: AppToastVariant.error,
          );
        case EditalEditorFeedback.falhaTecnica:
          AppToast.show(
            context,
            title: context.l10n.syllabusUpdateFailed,
            variant: AppToastVariant.error,
          );
        case null:
          break;
      }
    },
    builder: (context, state) => AppDrawer(
      title: context.l10n.syllabusTriageTitle,
      description: context.l10n.syllabusTriageDescription(institution, role),
      width: _editorWidth,
      scrollable: false,
      bodyPadding: EdgeInsets.zero,
      dismissible: !state.saving,
      footer: state.status == EditalEditorStatus.ready ? _EditorFooter(state: state) : null,
      child: _body(context, state),
    ),
  );

  Widget _body(BuildContext context, EditalEditorState state) => switch (state.status) {
    EditalEditorStatus.initial || EditalEditorStatus.loading => Padding(
      padding: EdgeInsets.all(context.tokens.spacing.xxl),
      child: AppSkeleton(height: 420, semanticLabel: context.l10n.loadingCatalog),
    ),
    EditalEditorStatus.failure => Padding(
      padding: EdgeInsets.all(context.tokens.spacing.xxl),
      child: AppStateView(
        variant: AppStateVariant.error,
        actionLabel: context.l10n.tryAgain,
        onAction: () => context.read<EditalEditorBloc>().add(const EditalEditorRetried()),
      ),
    ),
    EditalEditorStatus.ready => _TriageWorkspace(state: state),
  };
}

class _TriageWorkspace extends StatelessWidget {
  const _TriageWorkspace({required this.state});

  final EditalEditorState state;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth >= _desktopSplit) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: _disciplineRailWidth,
              child: _DisciplineRail(state: state),
            ),
            Expanded(child: _TopicPane(state: state)),
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 208, child: _DisciplineRail(state: state, compact: true)),
          Expanded(child: _TopicPane(state: state, compact: true)),
        ],
      );
    },
  );
}

class _DisciplineRail extends StatelessWidget {
  const _DisciplineRail({required this.state, this.compact = false});

  final EditalEditorState state;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          right: compact ? BorderSide.none : BorderSide(color: tokens.colors.border),
          bottom: compact ? BorderSide(color: tokens.colors.border) : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.spacing.xxl,
              tokens.spacing.sm,
              tokens.spacing.xl,
              tokens.spacing.md,
            ),
            child: Text(
              context.l10n.navigationDisciplines.toUpperCase(),
              style: tokens.typography.catalogOverline,
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: compact ? Axis.horizontal : Axis.vertical,
              padding: EdgeInsets.symmetric(horizontal: tokens.spacing.md),
              itemCount: state.catalogo.length,
              itemBuilder: (context, index) {
                final disciplina = state.catalogo[index];
                return SizedBox(
                  width: compact ? 248 : null,
                  child: _DisciplineItem(
                    disciplina: disciplina,
                    selectedCount: state.quantidadeSelecionada(disciplina),
                    active: disciplina.id == state.disciplinaSelecionada,
                    disabled: state.saving,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DisciplineItem extends StatelessWidget {
  const _DisciplineItem({
    required this.disciplina,
    required this.selectedCount,
    required this.active,
    required this.disabled,
  });

  final Disciplina disciplina;
  final int selectedCount;
  final bool active;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final topicCount = disciplina.topics.where((item) => !item.mandatory).length;
    final complete = topicCount > 0 && selectedCount == topicCount;
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.xxs, right: tokens.spacing.xxs),
      child: Material(
        color: active ? tokens.colors.surfaceSubtle : tokens.colors.transparent,
        borderRadius: tokens.borders.lg,
        child: InkWell(
          onTap: disabled
              ? null
              : () => context.read<EditalEditorBloc>().add(EditalEditorDisciplinaSelected(disciplina.id)),
          borderRadius: tokens.borders.lg,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.spacing.md, vertical: tokens.spacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        disciplina.name,
                        key: ValueKey('discipline-name-${disciplina.id}'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: active ? tokens.typography.disciplineSelected : tokens.typography.disciplineUnselected,
                      ),
                      SizedBox(height: tokens.spacing.xxxs),
                      Text(
                        context.l10n.syllabusTriageDisciplineProgress(selectedCount, topicCount),
                        style: tokens.typography.supportingText,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: tokens.spacing.sm),
                Icon(
                  complete ? AppIcons.checkCircle : AppIcons.chevronRight,
                  size: tokens.icons.sm,
                  color: complete
                      ? tokens.colors.success
                      : active
                      ? tokens.colors.onSurface
                      : tokens.colors.onSurfaceMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopicPane extends StatelessWidget {
  const _TopicPane({required this.state, this.compact = false});

  final EditalEditorState state;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final disciplina = state.disciplinaAtiva;
    if (disciplina == null) {
      return AppStateView(
        variant: AppStateVariant.empty,
        title: context.l10n.noDiscipline,
        message: context.l10n.noDisciplineMessage,
      );
    }
    final tokens = context.tokens;
    final topicCount = disciplina.topics.length;
    final header = _header(context, disciplina, topicCount);
    if (compact) {
      return ListView(
        padding: EdgeInsets.only(bottom: tokens.spacing.xxl),
        children: [
          header,
          if (state.topicosAtivos.isEmpty)
            AppStateView(
              variant: AppStateVariant.empty,
              title: context.l10n.noTopics,
              message: context.l10n.noTopicsMessage,
            )
          else
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.spacing.xxl),
              child: Column(
                children: [
                  for (var index = 0; index < state.topicosAtivos.length; index++) ...[
                    if (index > 0) const AppDivider(margin: EdgeInsets.zero),
                    _TopicItem(
                      topico: state.topicosAtivos[index],
                      selected:
                          state.topicosAtivos[index].mandatory ||
                          state.topicosVinculados.contains(state.topicosAtivos[index].id),
                      disabled: state.saving || state.topicosAtivos[index].mandatory,
                    ),
                  ],
                ],
              ),
            ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Expanded(
          child: state.topicosAtivos.isEmpty
              ? AppStateView(
                  variant: AppStateVariant.empty,
                  title: context.l10n.noTopics,
                  message: context.l10n.noTopicsMessage,
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    tokens.spacing.xxl,
                    tokens.spacing.none,
                    tokens.spacing.xxl,
                    tokens.spacing.xxl,
                  ),
                  itemCount: state.topicosAtivos.length,
                  separatorBuilder: (context, index) => const AppDivider(margin: EdgeInsets.zero),
                  itemBuilder: (context, index) => _TopicItem(
                    topico: state.topicosAtivos[index],
                    selected:
                        state.topicosAtivos[index].mandatory ||
                        state.topicosVinculados.contains(state.topicosAtivos[index].id),
                    disabled: state.saving || state.topicosAtivos[index].mandatory,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context, Disciplina disciplina, int topicCount) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.spacing.xxl,
        compact ? tokens.spacing.lg : tokens.spacing.sm,
        tokens.spacing.xxl,
        tokens.spacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: tokens.spacing.md,
            runSpacing: tokens.spacing.sm,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(disciplina.name, style: tokens.typography.titleLarge),
                  SizedBox(height: tokens.spacing.xxs),
                  Text(
                    context.l10n.topicsInCatalog(topicCount),
                    style: tokens.typography.supportingText,
                  ),
                ],
              ),
              Wrap(
                spacing: tokens.spacing.xs,
                runSpacing: tokens.spacing.xs,
                children: [
                  AppButton(
                    label: context.l10n.clear,
                    variant: AppButtonVariant.text,
                    onPressed: state.saving ? null : () => _changeAll(context, disciplina, selected: false),
                  ),
                  AppButton(
                    label: context.l10n.selectAll,
                    variant: AppButtonVariant.outline,
                    onPressed: state.saving ? null : () => _changeAll(context, disciplina, selected: true),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.lg),
          AppSearchField(
            key: ValueKey('topic-search-${disciplina.id}'),
            placeholder: context.l10n.filterDisciplineTopics,
            enabled: !state.saving,
            onChanged: (value) => context.read<EditalEditorBloc>().add(EditalEditorTopicoSearched(value)),
          ),
        ],
      ),
    );
  }

  void _changeAll(BuildContext context, Disciplina disciplina, {required bool selected}) {
    context.read<EditalEditorBloc>().add(
      EditalEditorDisciplinaSelectionChanged(disciplina: disciplina, selected: selected),
    );
  }
}

class _TopicItem extends StatelessWidget {
  const _TopicItem({required this.topico, required this.selected, required this.disabled});

  final Topico topico;
  final bool selected;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    void toggle() => context.read<EditalEditorBloc>().add(EditalEditorTopicoToggled(topico));
    return Material(
      color: tokens.colors.transparent,
      child: InkWell(
        onTap: disabled ? null : toggle,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: tokens.spacing.xs),
          child: Row(
            children: [
              AppCheckbox(
                value: selected,
                semanticLabel: topico.name,
                onChanged: disabled ? null : (_) => toggle(),
              ),
              SizedBox(width: tokens.spacing.sm),
              Expanded(
                child: Text(
                  topico.name,
                  key: ValueKey('topic-name-${topico.id}'),
                  style: tokens.typography.contentTitle,
                ),
              ),
              if (selected && !topico.mandatory) ...[
                SizedBox(width: tokens.spacing.md),
                Text(
                  context.l10n.inSyllabus,
                  style: tokens.typography.successLabel,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorFooter extends StatelessWidget {
  const _EditorFooter({required this.state});

  final EditalEditorState state;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: EdgeInsets.fromLTRB(
        tokens.spacing.xxl,
        tokens.spacing.md,
        tokens.spacing.xxl,
        tokens.spacing.lg,
      ),
      decoration: BoxDecoration(
        color: tokens.colors.surface,
        border: Border(top: BorderSide(color: tokens.colors.border)),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: AppButton(
          label: context.l10n.saveSelectedTopics(state.totalSelecionado),
          loading: state.saving,
          onPressed: state.temAlteracoes && !state.saving
              ? () => context.read<EditalEditorBloc>().add(const EditalEditorSaved())
              : null,
        ),
      ),
    );
  }
}
