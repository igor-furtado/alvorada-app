import '../../../disciplinas/domain/models/disciplina.dart';

sealed class EditalEditorEvent {
  const EditalEditorEvent();
}

final class EditalEditorLoaded extends EditalEditorEvent {
  const EditalEditorLoaded();
}

final class EditalEditorRetried extends EditalEditorEvent {
  const EditalEditorRetried();
}

final class EditalEditorDisciplinaAdded extends EditalEditorEvent {
  const EditalEditorDisciplinaAdded(this.disciplina);

  final Disciplina disciplina;
}

final class EditalEditorTopicoToggled extends EditalEditorEvent {
  const EditalEditorTopicoToggled(this.topico);

  final Topico topico;
}

final class EditalEditorDisciplinaSelected extends EditalEditorEvent {
  const EditalEditorDisciplinaSelected(this.disciplinaId);

  final String? disciplinaId;
}

final class EditalEditorDisciplinaSearched extends EditalEditorEvent {
  const EditalEditorDisciplinaSearched(this.query);

  final String query;
}

final class EditalEditorTopicoSearched extends EditalEditorEvent {
  const EditalEditorTopicoSearched(this.query);

  final String query;
}
