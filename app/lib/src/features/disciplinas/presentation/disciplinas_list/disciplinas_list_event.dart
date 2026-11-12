import 'disciplinas_list_state.dart';

sealed class DisciplinasListEvent {
  const DisciplinasListEvent();
}

final class DisciplinasListLoadRequested extends DisciplinasListEvent {
  const DisciplinasListLoadRequested();
}

final class DisciplinasListRefreshRequested extends DisciplinasListEvent {
  const DisciplinasListRefreshRequested({this.feedback, this.forceRefresh = false});

  final DisciplinasListFeedback? feedback;
  final bool forceRefresh;
}

final class DisciplinasListSearchChanged extends DisciplinasListEvent {
  const DisciplinasListSearchChanged(this.query);

  final String query;
}

final class DisciplinasListSelectionChanged extends DisciplinasListEvent {
  const DisciplinasListSelectionChanged(this.disciplineId);

  final String disciplineId;
}

final class DisciplinasListDeleteRequested extends DisciplinasListEvent {
  const DisciplinasListDeleteRequested(this.disciplineId);

  final String disciplineId;
}
