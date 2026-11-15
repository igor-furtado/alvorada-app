import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'concursos_list_actions.dart';
import 'concursos_list_bloc.dart';
import 'concursos_list_event.dart';
import 'concursos_list_state.dart';
import 'concursos_timeline.dart';

class ConcursosListView extends StatelessWidget {
  const ConcursosListView({super.key});

  @override
  Widget build(BuildContext context) => BlocConsumer<ConcursosListBloc, ConcursosListState>(
    listenWhen: (previous, current) => previous.feedback != current.feedback && current.feedback != null,
    listener: (context, state) => _showFeedback(context, state.feedback!),
    buildWhen: (previous, current) =>
        previous.status != current.status ||
        previous.items != current.items ||
        previous.isRefreshing != current.isRefreshing ||
        previous.isMutating != current.isMutating,
    builder: (context, state) => switch (state.status) {
      ConcursosListStatus.initial || ConcursosListStatus.loading => const _ConcursosListLoading(),
      ConcursosListStatus.failure => AppStateView(
        variant: AppStateVariant.error,
        actionLabel: context.l10n.tryAgain,
        onAction: () => context.read<ConcursosListBloc>().add(
          const ConcursosListLoadRequested(),
        ),
      ),
      ConcursosListStatus.success when state.items.isEmpty => AppStateView(
        variant: AppStateVariant.empty,
        title: context.l10n.nenhumConcursoAtivo,
        message: context.l10n.concursosEmpty,
        icon: AppIcons.concursos,
        actionLabel: context.l10n.novoConcurso,
        onAction: state.canMutate ? () => ConcursosListActions.add(context) : null,
      ),
      ConcursosListStatus.success => ConcursosTimeline(
        concursos: state.items,
        enabled: state.canMutate,
        actions: ConcursosTimelineActions(
          details: (concurso) => ConcursosListActions.details(context, concurso),
          openEdital: (concurso) => ConcursosListActions.openEdital(context, concurso),
          edit: (concurso) => ConcursosListActions.edit(context, concurso),
          prioritize: (concurso) => ConcursosListActions.prioritize(context, concurso),
          archive: (concurso) => ConcursosListActions.archive(context, concurso),
          delete: (concurso) => ConcursosListActions.delete(context, concurso),
        ),
      ),
    },
  );
}

class _ConcursosListLoading extends StatelessWidget {
  const _ConcursosListLoading();

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.carregandoConcursos,
    liveRegion: true,
    child: Column(
      children: [
        for (var index = 0; index < 3; index++) ...[
          const AppSkeleton(height: 240),
          if (index != 2) SizedBox(height: context.tokens.spacing.xl),
        ],
      ],
    ),
  );
}

void _showFeedback(
  BuildContext context,
  ConcursosListFeedback feedback,
) {
  switch (feedback.type) {
    case ConcursosListFeedbackType.archived:
      final concurso = feedback.concurso;
      if (concurso == null) return;
      AppToast.show(
        context,
        title: context.l10n.concursoArquivado(concurso.instituicao),
        variant: AppToastVariant.success,
        actionLabel: context.l10n.undo,
        onAction: () => context.read<ConcursosListBloc>().add(
          ConcursoRestoreRequested(concurso.id),
        ),
      );
    case ConcursosListFeedbackType.updated:
      _toast(context, context.l10n.concursoAtualizado, AppToastVariant.success);
    case ConcursosListFeedbackType.created:
      _toast(context, context.l10n.concursoCriado, AppToastVariant.success);
    case ConcursosListFeedbackType.prioritized:
      _toast(context, context.l10n.concursoPriorizado, AppToastVariant.success);
    case ConcursosListFeedbackType.restored:
      _toast(context, context.l10n.concursoRestaurado, AppToastVariant.success);
    case ConcursosListFeedbackType.deleted:
      _toast(context, context.l10n.concursoExcluido, AppToastVariant.success);
    case ConcursosListFeedbackType.refreshFailed:
      _toast(
        context,
        context.l10n.contentUpdateFailed,
        AppToastVariant.error,
      );
    case ConcursosListFeedbackType.synchronizationPending:
      AppToast.show(
        context,
        title: context.l10n.concursosSincronizacaoPendente,
        variant: AppToastVariant.info,
        actionLabel: context.l10n.update,
        onAction: () => context.read<ConcursosListBloc>().add(
          const ConcursosListRefreshRequested(forceRefresh: true),
        ),
      );
    case ConcursosListFeedbackType.operationFailed:
      _toast(
        context,
        context.l10n.concursoOperacaoFalhou,
        AppToastVariant.error,
      );
  }
}

void _toast(
  BuildContext context,
  String message,
  AppToastVariant variant,
) {
  AppToast.show(context, title: message, variant: variant);
}
