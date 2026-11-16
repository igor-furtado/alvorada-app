import 'package:estudos_app/features/disciplinas/domain/models/disciplina.dart';

sealed class EditalEditorEvent {
  const EditalEditorEvent();
}

final class EditalEditorLoaded extends EditalEditorEvent {
  const EditalEditorLoaded();
}

final class EditalEditorRetried extends EditalEditorEvent {
  const EditalEditorRetried();
}

final class EditalEditorTopicoToggled extends EditalEditorEvent {
  const EditalEditorTopicoToggled(this.topico);

  final Topico topico;
}

final class EditalEditorDisciplinaSelected extends EditalEditorEvent {
  const EditalEditorDisciplinaSelected(this.disciplinaId);

  final String disciplinaId;
}

final class EditalEditorDisciplinaSelectionChanged extends EditalEditorEvent {
  const EditalEditorDisciplinaSelectionChanged({required this.disciplina, required this.selected});

  final Disciplina disciplina;
  final bool selected;
}

final class EditalEditorTopicoSearched extends EditalEditorEvent {
  const EditalEditorTopicoSearched(this.query);

  final String query;
}

final class EditalEditorSaved extends EditalEditorEvent {
  const EditalEditorSaved();
}
