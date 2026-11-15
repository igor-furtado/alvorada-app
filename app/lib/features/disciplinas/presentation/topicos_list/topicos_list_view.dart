import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../disciplinas_list/disciplinas_list_state.dart';
import 'topicos_list_bloc.dart';
import 'topicos_list_event.dart';
import 'topicos_list_panel.dart';
import 'topicos_list_state.dart';

class TopicosListView extends StatelessWidget {
  const TopicosListView({
    required this.disciplina,
    required this.query,
    required this.canMutateDiscipline,
    required this.onRenameDiscipline,
    required this.onDeleteDiscipline,
    super.key,
  });

  final DisciplinaListItemData? disciplina;
  final String query;
  final bool canMutateDiscipline;
  final VoidCallback? onRenameDiscipline;
  final VoidCallback? onDeleteDiscipline;

  @override
  Widget build(BuildContext context) => BlocConsumer<TopicosListBloc, TopicosListState>(
    listenWhen: (previous, current) => previous.feedback != current.feedback && current.feedback != null,
    listener: (context, state) => _showFeedback(context, state.feedback!),
    buildWhen: (previous, current) =>
        previous.status != current.status ||
        previous.disciplineId != current.disciplineId ||
        !listEquals(previous.items, current.items) ||
        previous.isDeleting != current.isDeleting,
    builder: (context, state) => switch (state.status) {
      TopicosListStatus.initial => _empty(context),
      TopicosListStatus.loading => AppSkeleton(
        height: context.tokens.listItemMediaHeight,
        semanticLabel: context.l10n.loadingDisciplines,
      ),
      TopicosListStatus.failure => AppStateView(
        variant: AppStateVariant.error,
        actionLabel: context.l10n.tryAgain,
        onAction: () => context.read<TopicosListBloc>().add(
          const TopicosListRefreshRequested(),
        ),
      ),
      TopicosListStatus.success when disciplina != null => RepaintBoundary(
        child: TopicosListPanel(
          state: state,
          disciplina: disciplina!,
          query: query,
          canMutateDiscipline: canMutateDiscipline,
          onRenameDiscipline: onRenameDiscipline,
          onDeleteDiscipline: onDeleteDiscipline,
        ),
      ),
      TopicosListStatus.success => _empty(context),
    },
  );

  Widget _empty(BuildContext context) => Padding(
    padding: EdgeInsets.all(context.tokens.spacing.xxl),
    child: AppStateView(
      variant: AppStateVariant.empty,
      title: context.l10n.noContentFound,
      message: context.l10n.noContentFoundMessage,
    ),
  );
}

void _showFeedback(BuildContext context, TopicosListFeedback feedback) {
  final (message, variant) = switch (feedback) {
    TopicosListFeedback.created => (context.l10n.topicCreated, AppToastVariant.success),
    TopicosListFeedback.renamed => (context.l10n.topicUpdated, AppToastVariant.success),
    TopicosListFeedback.deleted => (context.l10n.topicDeleted, AppToastVariant.success),
    TopicosListFeedback.synchronizationPending => (
      context.l10n.contentSavedSyncPending,
      AppToastVariant.info,
    ),
    TopicosListFeedback.operationFailed => (context.l10n.contentOperationFailed, AppToastVariant.error),
  };
  AppToast.show(context, title: message, variant: variant);
}
