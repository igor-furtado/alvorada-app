import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../topicos_form/topicos_form_view.dart';
import 'topicos_list_bloc.dart';
import 'topicos_list_event.dart';
import 'topicos_list_state.dart';

abstract final class TopicosListActions {
  static Future<void> manage(
    BuildContext context,
    String disciplineId,
    String disciplineName,
    List<TopicoListItemData> topics,
  ) async {
    final saved = await showAppDrawerBuilder<bool>(
      context,
      builder: (_) => TopicosFormView(
        disciplineId: disciplineId,
        disciplineName: disciplineName,
        topics: topics,
      ),
    );
    if (saved == true && context.mounted) {
      context.read<TopicosListBloc>().add(
        const TopicosListRefreshRequested(
          feedback: TopicosListFeedback.renamed,
        ),
      );
    }
  }
}
