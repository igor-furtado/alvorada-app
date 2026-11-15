sealed class ConcursoDetailsEvent {
  const ConcursoDetailsEvent();
}

final class ConcursoDetailsLoadRequested extends ConcursoDetailsEvent {
  const ConcursoDetailsLoadRequested({this.forceRefresh = false});

  final bool forceRefresh;
}

final class ConcursoDetailsQueryChanged extends ConcursoDetailsEvent {
  const ConcursoDetailsQueryChanged(this.query);

  final String query;
}

final class ConcursoDetailsTabChanged extends ConcursoDetailsEvent {
  const ConcursoDetailsTabChanged(this.tab);

  final ConcursoDetailsTab tab;
}

enum ConcursoDetailsTab { edital, informacoes }
