import '../../domain/models/planejamento_semanal.dart';
import '../../domain/repositories/semana_repository.dart';
import '../services/semana_api_service.dart';

class ApiSemanaRepository implements SemanaRepository {
  const ApiSemanaRepository(this._api);

  final SemanaApi _api;

  @override
  Future<PlanejamentoSemanal> getPlanejamento({required DateTime inicio, required DateTime fim}) async {
    try {
      return (await _api.getPlanejamento(inicio, fim)).toDomain();
    } on Object catch (error) {
      throw SemanaRepositoryException('Não foi possível carregar a semana.', error);
    }
  }

  @override
  Future<void> planejarTopico({
    required String concursoId,
    required String topicoId,
    required DateTime data,
    int posicaoDia = 0,
  }) => _mutate(
    () => _api.planejarTopico(
      concursoId: concursoId,
      topicoId: topicoId,
      data: data,
      posicaoDia: posicaoDia,
    ),
  );

  @override
  Future<void> atualizarProgresso({
    required String concursoId,
    required String topicoId,
    required ProgressoTopicoInput input,
  }) => _mutate(
    () => _api.atualizarProgresso(
      concursoId: concursoId,
      topicoId: topicoId,
      body: {
        if (input.teoriaConcluida != null) 'teoria_concluida': input.teoriaConcluida,
        if (input.memoriaConcluida != null) 'memoria_concluida': input.memoriaConcluida,
        if (input.conferenciaConcluida != null) 'conferencia_concluida': input.conferenciaConcluida,
      },
    ),
  );

  @override
  Future<void> registrarQuestao({
    required String concursoId,
    required String topicoId,
    required ResultadoQuestao resultado,
  }) => _mutate(
    () => _api.registrarQuestao(
      concursoId: concursoId,
      topicoId: topicoId,
      resultado: resultado.name,
    ),
  );

  @override
  Future<void> substituirRevisoes({
    required String concursoId,
    required String topicoId,
    required Set<int> intervalosDias,
  }) => _mutate(
    () => _api.substituirRevisoes(
      concursoId: concursoId,
      topicoId: topicoId,
      intervalosDias: intervalosDias.toList(growable: false)..sort(),
    ),
  );

  @override
  Future<void> moverRevisao({
    required String revisaoId,
    required DateTime data,
    int posicaoDia = 0,
  }) => _mutate(
    () => _api.moverRevisao(revisaoId: revisaoId, data: data, posicaoDia: posicaoDia),
  );

  @override
  Future<void> concluirRevisao(String revisaoId) => _mutate(() => _api.concluirRevisao(revisaoId));

  Future<void> _mutate(Future<void> Function() operation) async {
    try {
      await operation();
    } on SemanaApiException catch (error) {
      if (error.statusCode >= 400 && error.statusCode < 500) {
        throw SemanaRuleViolationException(error.message, error);
      }
      throw SemanaRepositoryException('Não foi possível atualizar a semana.', error);
    } on Object catch (error) {
      throw SemanaRepositoryException('Não foi possível atualizar a semana.', error);
    }
  }
}
