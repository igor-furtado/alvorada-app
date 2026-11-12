import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
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
        height: context.tokens.sizes.listItemHeaderHeight,
        semanticLabel: AppMessages.loadingDisciplines,
      ),
      TopicosListStatus.failure => AppStateView(
        variant: AppStateVariant.error,
        actionLabel: AppMessages.tryAgain,
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
    child: const AppStateView(
      variant: AppStateVariant.empty,
      title: AppMessages.noContentFound,
      message: AppMessages.noContentFoundMessage,
    ),
  );
}

void _showFeedback(BuildContext context, TopicosListFeedback feedback) {
  final (message, variant) = switch (feedback) {
    TopicosListFeedback.created => (AppMessages.topicCreated, AppToastVariant.success),
    TopicosListFeedback.renamed => (AppMessages.topicUpdated, AppToastVariant.success),
    TopicosListFeedback.deleted => (AppMessages.topicDeleted, AppToastVariant.success),
    TopicosListFeedback.synchronizationPending => (
      AppMessages.contentSavedSyncPending,
      AppToastVariant.info,
    ),
    TopicosListFeedback.operationFailed => (AppMessages.contentOperationFailed, AppToastVariant.error),
  };
  AppToast.show(context, title: message, variant: variant);
}
