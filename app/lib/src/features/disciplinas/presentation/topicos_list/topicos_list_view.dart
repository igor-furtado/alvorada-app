import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
import 'topicos_list_bloc.dart';
import 'topicos_list_event.dart';
import 'topicos_list_panel.dart';
import 'topicos_list_state.dart';

class TopicosListView extends StatelessWidget {
  const TopicosListView({super.key});

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
      TopicosListStatus.loading => const AppSkeleton(
        height: double.infinity,
        semanticLabel: AppMessages.loadingDisciplines,
      ),
      TopicosListStatus.failure => AppStateView(
        variant: AppStateVariant.error,
        actionLabel: AppMessages.tryAgain,
        onAction: () => context.read<TopicosListBloc>().add(
          const TopicosListRefreshRequested(),
        ),
      ),
      TopicosListStatus.success => RepaintBoundary(
        child: TopicosListPanel(state: state),
      ),
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
