import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/concurso.dart';
import '../concurso_view_data.dart';
import '../concursos_form/concursos_form_view.dart';
import '../edital_editor/edital_editor_view.dart';
import 'concurso_details_bloc.dart';
import 'concurso_details_event.dart';
import 'concurso_details_header.dart';
import 'concurso_details_state.dart';
import 'concurso_information.dart';
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
    await showAppDrawerBuilder<void>(
      context,
      builder: (_) => EditalEditorView(concurso: concurso),
    );
    if (!context.mounted) return;
    context.read<ConcursoDetailsBloc>().add(const ConcursoDetailsLoadRequested(forceRefresh: true));
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
  });

  final ConcursoDetailsState state;
  final ValueChanged<Concurso> onEditConcurso;
  final ValueChanged<Concurso> onEditEdital;
  final ValueChanged<DisciplinaEdital> onOpenDisciplina;

  @override
  Widget build(BuildContext context) {
    final concurso = state.concurso!;
    final view = ConcursoViewData.fromDomain(concurso, context.l10n);
    final bloc = context.read<ConcursoDetailsBloc>();
    return AppPage.scroll(
      key: PageStorageKey<String>('concurso-${concurso.id}'),
      headerLeading: ConcursoDetailsHeader(concurso: view),
      title: view.institution,
      description: view.organizationAcronym ?? view.role,
      headerAction: AppButton(
        label: context.l10n.editarConcurso,
        icon: AppIcons.edit,
        variant: AppButtonVariant.outline,
        onPressed: () => onEditConcurso(concurso),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          AppTabs<ConcursoDetailsTab>(
            initialValue: ConcursoDetailsTab.edital,
            value: state.tab,
            onChanged: (tab) => bloc.add(ConcursoDetailsTabChanged(tab)),
            variant: AppTabsVariant.line,
            trailing: ConcursoDetailsFacts(concurso: view),
            items: [
              AppTabItem(
                value: ConcursoDetailsTab.edital,
                label: context.l10n.notice,
                content: EditalOverview(
                  concurso: concurso,
                  query: state.query,
                  onQueryChanged: (query) => bloc.add(ConcursoDetailsQueryChanged(query)),
                  onEdit: () => onEditEdital(concurso),
                  onSeeRole: () => bloc.add(
                    const ConcursoDetailsTabChanged(ConcursoDetailsTab.informacoes),
                  ),
                  onOpenDisciplina: onOpenDisciplina,
                ),
              ),
              AppTabItem(
                value: ConcursoDetailsTab.informacoes,
                label: context.l10n.information,
                content: ConcursoInformation(concurso: view),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
