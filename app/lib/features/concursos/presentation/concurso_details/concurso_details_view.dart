import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:estudos_app/core/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/models/concurso.dart';
import '../../domain/use_cases/concursos_use_cases.dart';
import '../concurso_view_data.dart';
import '../concursos_form/concursos_form_view.dart';
import '../edital_editor/edital_editor_view.dart';
import 'concurso_details_bloc.dart';
import 'concurso_details_event.dart';
import 'concurso_details_header.dart';
import 'concurso_details_state.dart';
import 'edital_overview.dart';

const _overviewPlaceholderHeight = 240.0;

class ConcursoDetailsView extends StatelessWidget {
  const ConcursoDetailsView({super.key});

  Future<void> _editConcurso(BuildContext context, Concurso concurso) async {
    final saved = await showAppDrawerBuilder<bool>(
      context,
      builder: (_) => ConcursosFormView(concurso: concurso),
    );
    if (saved != true || !context.mounted) return;
    context.read<ConcursoDetailsBloc>().add(const ConcursoDetailsLoadRequested(forceRefresh: true));
    AppToast.show(
      context,
      title: context.l10n.concursoAtualizado,
      variant: AppToastVariant.success,
    );
  }

  Future<void> _editEdital(BuildContext context, Concurso concurso) async {
    final saved = await showAppDrawerBuilder<bool>(
      context,
      builder: (_) => EditalEditorView(concurso: concurso),
    );
    if (saved != true || !context.mounted) return;
    context.read<ConcursoDetailsBloc>().add(const ConcursoDetailsLoadRequested(forceRefresh: true));
    AppToast.show(
      context,
      title: context.l10n.syllabusSaved,
      variant: AppToastVariant.success,
    );
  }

  Future<void> _openDisciplina(BuildContext context, DisciplinaEdital disciplina) => showAppDrawerBuilder<void>(
    context,
    builder: (_) => AppDrawer(
      eyebrow: context.l10n.syllabusContentEyebrow,
      title: disciplina.nome,
      description: context.l10n.topicsInSyllabusDescription,
      child: AppListItemGroup(
        spacing: 0,
        children: [
          for (final topico in disciplina.topicos)
            AppListItem(
              title: topico.nome,
              leadingIcon: topico.obrigatorio ? AppIcons.lockedTopic : AppIcons.bookText,
              badge: topico.obrigatorio ? context.l10n.protected : null,
            ),
        ],
      ),
    ),
  );

  Future<bool> _updateWeight(
    BuildContext context,
    Concurso concurso,
    DisciplinaEdital disciplina,
    double peso,
  ) async {
    final result = await context.read<ConcursosUseCases>().edital.updateDisciplinaPeso(
      concursoId: concurso.id,
      disciplinaId: disciplina.id,
      peso: peso,
    );
    if (!context.mounted) return false;
    return switch (result) {
      Sucesso<void>() => () {
        context.read<ConcursoDetailsBloc>().add(
          const ConcursoDetailsLoadRequested(forceRefresh: true),
        );
        AppToast.show(
          context,
          title: context.l10n.weightUpdated,
          variant: AppToastVariant.success,
        );
        return true;
      }(),
      ViolacaoRegra<void>() || FalhaTecnica<void>() => () {
        AppToast.show(
          context,
          title: context.l10n.weightUpdateFailed,
          variant: AppToastVariant.error,
        );
        return false;
      }(),
    };
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ConcursoDetailsBloc, ConcursoDetailsState>(
    builder: (context, state) => ColoredBox(
      color: context.tokens.colors.canvas,
      child: switch (state.status) {
        ConcursoDetailsStatus.initial || ConcursoDetailsStatus.loading => AppPage.scroll(
          title: context.l10n.navigationConcursos,
          description: context.l10n.carregandoConcursos,
          child: AppSkeleton(
            height: _overviewPlaceholderHeight,
            semanticLabel: context.l10n.carregandoConcursos,
          ),
        ),
        ConcursoDetailsStatus.notFound => AppPage.scroll(
          title: context.l10n.navigationConcursos,
          description: context.l10n.concursoNotFoundMessage,
          child: AppStateView(
            variant: AppStateVariant.empty,
            title: context.l10n.concursoNaoEncontrado,
            message: context.l10n.concursoNotFoundMessage,
          ),
        ),
        ConcursoDetailsStatus.failure => AppPage.scroll(
          title: context.l10n.navigationConcursos,
          description: context.l10n.genericErrorMessage,
          child: AppStateView(
            variant: AppStateVariant.error,
            title: context.l10n.genericErrorTitle,
            message: context.l10n.genericErrorMessage,
            actionLabel: context.l10n.tryAgain,
            onAction: () => context.read<ConcursoDetailsBloc>().add(
              const ConcursoDetailsLoadRequested(forceRefresh: true),
            ),
          ),
        ),
        ConcursoDetailsStatus.success => _SuccessView(
          state: state,
          onEditConcurso: (concurso) => _editConcurso(context, concurso),
          onEditEdital: (concurso) => _editEdital(context, concurso),
          onOpenDisciplina: (disciplina) => _openDisciplina(context, disciplina),
          onWeightChanged: (concurso, disciplina, peso) => _updateWeight(context, concurso, disciplina, peso),
        ),
      },
    ),
  );
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({
    required this.state,
    required this.onEditConcurso,
    required this.onEditEdital,
    required this.onOpenDisciplina,
    required this.onWeightChanged,
  });

  final ConcursoDetailsState state;
  final ValueChanged<Concurso> onEditConcurso;
  final ValueChanged<Concurso> onEditEdital;
  final ValueChanged<DisciplinaEdital> onOpenDisciplina;
  final Future<bool> Function(Concurso concurso, DisciplinaEdital disciplina, double peso) onWeightChanged;

  @override
  Widget build(BuildContext context) {
    final concurso = state.concurso!;
    final view = ConcursoViewData.fromDomain(concurso, context.l10n);
    final bloc = context.read<ConcursoDetailsBloc>();
    return SafeArea(
      child: ResponsiveBuilder(
        builder: (context, windowClass) {
          final padding = windowClass.isExpanded ? context.tokens.spacing.page : context.tokens.spacing.xl;
          return SingleChildScrollView(
            key: PageStorageKey<String>('concurso-${concurso.id}'),
            padding: EdgeInsets.fromLTRB(
              padding,
              padding,
              padding,
              context.tokens.spacing.huge,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: context.tokens.layout.contentMaxWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConcursoDetailsHeader(concurso: view),
                    SizedBox(height: context.tokens.spacing.xl),
                    if (state.refreshFailed) ...[
                      AppAlert(
                        title: context.l10n.genericErrorTitle,
                        description: context.l10n.genericErrorMessage,
                        icon: AppIcons.attention,
                      ),
                      SizedBox(height: context.tokens.spacing.sm),
                      Align(
                        alignment: Alignment.centerRight,
                        child: AppButton(
                          label: context.l10n.tryAgain,
                          variant: AppButtonVariant.outline,
                          onPressed: () => bloc.add(
                            const ConcursoDetailsLoadRequested(forceRefresh: true),
                          ),
                        ),
                      ),
                      SizedBox(height: context.tokens.spacing.xl),
                    ],
                    EditalOverview(
                      concurso: concurso,
                      view: view,
                      query: state.query,
                      onQueryChanged: (query) => bloc.add(ConcursoDetailsQueryChanged(query)),
                      onEditConcurso: () => onEditConcurso(concurso),
                      onEditEdital: () => onEditEdital(concurso),
                      onOpenDisciplina: onOpenDisciplina,
                      onWeightChanged: (disciplina, peso) => onWeightChanged(concurso, disciplina, peso),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
