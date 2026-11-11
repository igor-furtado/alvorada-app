import '../models/concurso.dart';
import '../models/concurso_input.dart';

abstract interface class ConcursosRepository {
  Future<List<Concurso>> getConcursos({bool forceRefresh = false});

  Future<Concurso> createConcurso(CreateConcursoInput input);

  Future<void> setPrioritario(String id);

  Future<void> archiveConcurso(String id);

  Future<void> restoreConcurso(String id);

  Future<void> deleteConcurso(String id);
}

class ConcursosRepositoryException implements Exception {
  const ConcursosRepositoryException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class ConcursosSynchronizationException extends ConcursosRepositoryException {
  const ConcursosSynchronizationException([Object? cause])
    : super('A alteração foi salva, mas os Concursos não puderam ser atualizados.', cause);
}
