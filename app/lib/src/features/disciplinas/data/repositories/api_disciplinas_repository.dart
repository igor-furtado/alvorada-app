import '../../domain/models/disciplina.dart';
import '../../domain/models/disciplina_input.dart';
import '../../domain/repositories/disciplinas_repository.dart';
import '../services/disciplinas_api_service.dart';

class ApiDisciplinasRepository implements DisciplinasRepository {
  ApiDisciplinasRepository(this._api);

  final DisciplinasApi _api;
  List<Disciplina>? _cache;

  @override
  Future<List<Disciplina>> getDisciplinas({bool forceRefresh = false}) async {
    final cache = _cache;
    if (!forceRefresh && cache != null) return cache;
    return _refresh();
  }

  @override
  Future<Disciplina> createDisciplina(CreateDisciplinaInput input) async {
    late final String id;
    try {
      id = await _api.createDisciplina({
        'nome': input.name,
        'dificuldade': input.difficulty.apiValue,
        'cor': input.color,
      });
    } on DisciplinasRepositoryException {
      rethrow;
    } on DisciplinasApiException catch (error) {
      throw _translateApiError(error, 'Não foi possível criar a Disciplina.');
    } on Object catch (error) {
      throw DisciplinasRepositoryException('Não foi possível criar a Disciplina.', error);
    }
    final disciplinas = await _refreshAfterMutation();
    try {
      return disciplinas.firstWhere(
        (discipline) => discipline.id == id,
        orElse: () => throw const FormatException('A API criou a Disciplina, mas não a retornou no catálogo.'),
      );
    } on Object catch (error) {
      _cache = null;
      throw DisciplinasSynchronizationException(error);
    }
  }

  @override
  Future<void> updateDisciplina(String id, UpdateDisciplinaInput input) async {
    if (!input.hasChanges) return;
    final body = <String, Object?>{
      'nome': ?input.name,
      'dificuldade': ?input.difficulty?.apiValue,
      'cor': ?input.color,
    };
    await _mutate(() => _api.updateDisciplina(id, body), 'Não foi possível atualizar a Disciplina.');
  }

  @override
  Future<void> deleteDisciplina(String id) =>
      _mutate(() => _api.deleteDisciplina(id), 'Não foi possível excluir a Disciplina.');

  @override
  Future<void> createTopicos({required String disciplineId, required List<String> names}) => _mutate(
    () => _api.createTopicos(disciplineId, names),
    'Não foi possível adicionar o Tópico.',
  );

  @override
  Future<void> updateTopico({required String topicId, required String name}) =>
      _mutate(() => _api.updateTopico(topicId, name), 'Não foi possível atualizar o Tópico.');

  @override
  Future<void> deleteTopico(String topicId) =>
      _mutate(() => _api.deleteTopico(topicId), 'Não foi possível excluir o Tópico.');

  Future<List<Disciplina>> _refresh() async {
    try {
      final response = await _api.getDisciplinas();
      final disciplines = List<Disciplina>.unmodifiable(response.map((item) => item.toDomain()));
      _cache = disciplines;
      return disciplines;
    } on Object catch (error) {
      throw DisciplinasRepositoryException('Não foi possível carregar as Disciplinas.', error);
    }
  }

  Future<void> _mutate(Future<void> Function() operation, String message) async {
    try {
      await operation();
    } on DisciplinasRepositoryException {
      rethrow;
    } on DisciplinasApiException catch (error) {
      throw _translateApiError(error, message);
    } on Object catch (error) {
      throw DisciplinasRepositoryException(message, error);
    }
    await _refreshAfterMutation();
  }

  DisciplinasRepositoryException _translateApiError(
    DisciplinasApiException error,
    String technicalMessage,
  ) {
    if (error.statusCode >= 400 && error.statusCode < 500) {
      return DisciplinasRuleViolationException(
        code: 'disciplinas.api.${error.statusCode}',
        message: error.message,
        cause: error,
      );
    }
    return DisciplinasRepositoryException(technicalMessage, error);
  }

  Future<List<Disciplina>> _refreshAfterMutation() async {
    try {
      return await _refresh();
    } on Object catch (error) {
      _cache = null;
      throw DisciplinasSynchronizationException(error);
    }
  }
}
