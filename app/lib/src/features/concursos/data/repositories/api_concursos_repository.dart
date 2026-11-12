import '../../domain/models/concurso.dart';
import '../../domain/models/concurso_input.dart';
import '../../domain/repositories/concursos_repository.dart';
import '../services/concursos_api_service.dart';

class ApiConcursosRepository implements ConcursosRepository {
  ApiConcursosRepository(this._api);

  final ConcursosApi _api;
  List<Concurso>? _cache;

  @override
  Future<List<Concurso>> getConcursos({bool forceRefresh = false}) async {
    final cache = _cache;
    if (!forceRefresh && cache != null) return cache;
    return _refresh();
  }

  @override
  Future<Concurso> createConcurso(CreateConcursoInput input) async {
    late final String id;
    try {
      id = await _api.createConcurso({
        'instituicao': input.instituicao,
        'cargo': input.cargo,
        'banca': input.banca,
        'data_prova': input.dataProva == null ? null : _dateOnly(input.dataProva!),
        'prioritario': input.prioritario,
        'sigla': input.sigla,
        'quantidade_vagas': input.quantidadeVagas,
        'vencimento_centavos': input.vencimentoCentavos,
        'carga_horaria_semanal': input.cargaHorariaSemanal,
        'local_prova': input.localProva,
        'horario_inicio_prova': input.horarioInicioProva,
        'horario_fim_prova': input.horarioFimProva,
        'requisitos': input.requisitos,
        'criterios_pontuacao': input.criteriosPontuacao,
      });
    } on Object catch (error) {
      throw ConcursosRepositoryException('Não foi possível criar o Concurso.', error);
    }
    final concursos = await _refreshAfterMutation();
    try {
      return concursos.firstWhere(
        (concurso) => concurso.id == id,
        orElse: () => throw const FormatException('A API criou o Concurso, mas não o retornou na lista.'),
      );
    } on Object catch (error) {
      _cache = null;
      throw ConcursosSynchronizationException(error);
    }
  }

  @override
  Future<void> updateConcurso(String id, UpdateConcursoInput input) => _mutate(
    () => _api.updateConcurso(id, _body(input)),
    'Não foi possível atualizar o Concurso.',
  );

  @override
  Future<void> setPrioritario(String id) =>
      _mutate(() => _api.setPrioritario(id), 'Não foi possível definir o Concurso prioritário.');

  @override
  Future<void> archiveConcurso(String id) =>
      _mutate(() => _api.archiveConcurso(id), 'Não foi possível arquivar o Concurso.');

  @override
  Future<void> restoreConcurso(String id) =>
      _mutate(() => _api.restoreConcurso(id), 'Não foi possível restaurar o Concurso.');

  @override
  Future<void> deleteConcurso(String id) =>
      _mutate(() => _api.deleteConcurso(id), 'Não foi possível excluir o Concurso.');

  Future<List<Concurso>> _refresh() async {
    try {
      final concursos = (await _api.getConcursos()).map((item) => item.toDomain()).toList(growable: false);
      _cache = List.unmodifiable(concursos);
      return _cache!;
    } on ConcursosRepositoryException {
      rethrow;
    } on Object catch (error) {
      throw ConcursosRepositoryException('Não foi possível carregar os Concursos.', error);
    }
  }

  Future<List<Concurso>> _refreshAfterMutation() async {
    _cache = null;
    try {
      return await _refresh();
    } on Object catch (error) {
      throw ConcursosSynchronizationException(error);
    }
  }

  Future<void> _mutate(Future<void> Function() operation, String message) async {
    try {
      await operation();
    } on Object catch (error) {
      throw ConcursosRepositoryException(message, error);
    }
    await _refreshAfterMutation();
  }
}

String _dateOnly(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

Map<String, Object?> _body(UpdateConcursoInput input) => {
  'instituicao': input.instituicao,
  'cargo': input.cargo,
  'banca': input.banca,
  'data_prova': input.dataProva == null ? null : _dateOnly(input.dataProva!),
  'prioritario': input.prioritario,
  'sigla': input.sigla,
  'quantidade_vagas': input.quantidadeVagas,
  'vencimento_centavos': input.vencimentoCentavos,
  'carga_horaria_semanal': input.cargaHorariaSemanal,
  'local_prova': input.localProva,
  'horario_inicio_prova': input.horarioInicioProva,
  'horario_fim_prova': input.horarioFimProva,
  'requisitos': input.requisitos,
  'criterios_pontuacao': input.criteriosPontuacao,
};
