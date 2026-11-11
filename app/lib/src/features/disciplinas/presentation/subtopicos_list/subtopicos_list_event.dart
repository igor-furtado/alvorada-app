import 'subtopicos_list_state.dart';

sealed class SubtopicosListEvent {
  const SubtopicosListEvent();
}

final class SubtopicosListDisciplineChanged extends SubtopicosListEvent {
  const SubtopicosListDisciplineChanged(this.disciplineId);

  final String? disciplineId;
}

final class SubtopicosListRefreshRequested extends SubtopicosListEvent {
  const SubtopicosListRefreshRequested({this.feedback});

  final SubtopicosListFeedback? feedback;
}

final class SubtopicosListDeleteRequested extends SubtopicosListEvent {
  const SubtopicosListDeleteRequested(this.subtopicId);

  final String subtopicId;
}
