import '../../domain/models/disciplina_input.dart';

sealed class DisciplinasEvent {
  const DisciplinasEvent();
}

final class LoadDisciplinasRequested extends DisciplinasEvent {
  const LoadDisciplinasRequested();
}

final class RefreshDisciplinasRequested extends DisciplinasEvent {
  const RefreshDisciplinasRequested();
}

final class SearchDisciplinasChanged extends DisciplinasEvent {
  const SearchDisciplinasChanged(this.query);

  final String query;
}

final class ToggleTopicoRequested extends DisciplinasEvent {
  const ToggleTopicoRequested(this.topicId);

  final String topicId;
}

final class CreateDisciplinaRequested extends DisciplinasEvent {
  const CreateDisciplinaRequested(this.input);

  final CreateDisciplinaInput input;
}

final class UpdateDisciplinaRequested extends DisciplinasEvent {
  const UpdateDisciplinaRequested({required this.disciplineId, required this.input});

  final String disciplineId;
  final UpdateDisciplinaInput input;
}

final class DeleteDisciplinaRequested extends DisciplinasEvent {
  const DeleteDisciplinaRequested(this.disciplineId);

  final String disciplineId;
}

final class CreateTopicoRequested extends DisciplinasEvent {
  const CreateTopicoRequested({required this.disciplineId, required this.name});

  final String disciplineId;
  final String name;
}

final class UpdateTopicoRequested extends DisciplinasEvent {
  const UpdateTopicoRequested({required this.topicId, required this.name});

  final String topicId;
  final String name;
}

final class DeleteTopicoRequested extends DisciplinasEvent {
  const DeleteTopicoRequested(this.topicId);

  final String topicId;
}

final class CreateSubtopicoRequested extends DisciplinasEvent {
  const CreateSubtopicoRequested({required this.topicId, required this.name});

  final String topicId;
  final String name;
}

final class UpdateSubtopicoRequested extends DisciplinasEvent {
  const UpdateSubtopicoRequested({required this.subtopicId, required this.name});

  final String subtopicId;
  final String name;
}

final class DeleteSubtopicoRequested extends DisciplinasEvent {
  const DeleteSubtopicoRequested(this.subtopicId);

  final String subtopicId;
}
