import 'concursos_list_state.dart';

sealed class ConcursosListEvent {
  const ConcursosListEvent();
}

final class ConcursosListLoadRequested extends ConcursosListEvent {
  const ConcursosListLoadRequested();
}

final class ConcursosListRefreshRequested extends ConcursosListEvent {
  const ConcursosListRefreshRequested({
    this.feedback,
    this.forceRefresh = false,
  });

  final ConcursosListFeedback? feedback;
  final bool forceRefresh;
}

final class ConcursoPrioritarioSetRequested extends ConcursosListEvent {
  const ConcursoPrioritarioSetRequested(this.concursoId);

  final String concursoId;
}

final class ConcursoArchiveRequested extends ConcursosListEvent {
  const ConcursoArchiveRequested(this.concursoId);

  final String concursoId;
}

final class ConcursoRestoreRequested extends ConcursosListEvent {
  const ConcursoRestoreRequested(this.concursoId);

  final String concursoId;
}

final class ConcursoDeleteRequested extends ConcursosListEvent {
  const ConcursoDeleteRequested(this.concursoId);

  final String concursoId;
}
