import '../models/disciplina.dart';
import '../models/disciplina_input.dart';

abstract interface class DisciplinasRepository {
  Future<List<Disciplina>> getDisciplinas({bool forceRefresh = false});

  Future<Disciplina> createDisciplina(CreateDisciplinaInput input);

  Future<void> updateDisciplina(String id, UpdateDisciplinaInput input);

  Future<void> deleteDisciplina(String id);

  Future<void> createTopicos({required String disciplineId, required List<String> names});

  Future<void> updateTopico({required String topicId, required String name});

  Future<void> deleteTopico(String topicId);
}

class DisciplinasRepositoryException implements Exception {
  const DisciplinasRepositoryException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class DisciplinasRuleViolationException extends DisciplinasRepositoryException {
  const DisciplinasRuleViolationException({
    required this.code,
    required String message,
    Object? cause,
  }) : super(message, cause);

  final String code;
}

class DisciplinasSynchronizationException extends DisciplinasRepositoryException {
  const DisciplinasSynchronizationException([Object? cause])
    : super(
        'A alteração foi salva, mas o catálogo não pôde ser atualizado.',
        cause,
      );
}
