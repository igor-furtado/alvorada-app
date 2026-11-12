import 'topicos_list_state.dart';

sealed class TopicosListEvent {
  const TopicosListEvent();
}

final class TopicosListDisciplineChanged extends TopicosListEvent {
  const TopicosListDisciplineChanged(this.disciplineId);

  final String? disciplineId;
}

final class TopicosListRefreshRequested extends TopicosListEvent {
  const TopicosListRefreshRequested({this.feedback});

  final TopicosListFeedback? feedback;
}

final class TopicosListDeleteRequested extends TopicosListEvent {
  const TopicosListDeleteRequested(this.topicId);

  final String topicId;
}
