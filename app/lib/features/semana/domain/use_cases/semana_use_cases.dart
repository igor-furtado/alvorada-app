import 'package:estudos_app/core/result.dart';

import '../models/planejamento_semanal.dart';
import '../repositories/semana_repository.dart';

class SemanaUseCases {
  const SemanaUseCases(this._repository);

  final SemanaRepository _repository;

  Future<Resultado<PlanejamentoSemanal>> carregar(DateTime inicio, DateTime fim) => _run(
    () => _repository.getPlanejamento(inicio: inicio, fim: fim),
  );

  Future<Resultado<void>> planejar({
    required String concursoId,
    required String topicoId,
    required DateTime data,
    int posicaoDia = 0,
  }) => _run(
    () => _repository.planejarTopico(
      concursoId: concursoId,
      topicoId: topicoId,
      data: data,
      posicaoDia: posicaoDia,
    ),
  );

  Future<Resultado<void>> atualizarProgresso({
    required String concursoId,
    required String topicoId,
    required ProgressoTopicoInput input,
  }) => _run(
    () => _repository.atualizarProgresso(
      concursoId: concursoId,
      topicoId: topicoId,
      input: input,
    ),
  );

  Future<Resultado<void>> registrarQuestao({
    required String concursoId,
    required String topicoId,
    required ResultadoQuestao resultado,
  }) => _run(
    () => _repository.registrarQuestao(
      concursoId: concursoId,
      topicoId: topicoId,
      resultado: resultado,
    ),
  );

  Future<Resultado<void>> substituirRevisoes({
    required String concursoId,
    required String topicoId,
    required Set<int> intervalosDias,
  }) => _run(
    () => _repository.substituirRevisoes(
      concursoId: concursoId,
      topicoId: topicoId,
      intervalosDias: intervalosDias,
    ),
  );

  Future<Resultado<void>> moverRevisao({
    required String revisaoId,
    required DateTime data,
    int posicaoDia = 0,
  }) => _run(
    () => _repository.moverRevisao(
      revisaoId: revisaoId,
      data: data,
      posicaoDia: posicaoDia,
    ),
  );

  Future<Resultado<void>> concluirRevisao(String revisaoId) => _run(
    () => _repository.concluirRevisao(revisaoId),
  );
}

Future<Resultado<T>> _run<T>(Future<T> Function() operation) async {
  try {
    return Sucesso(await operation());
  } on SemanaRuleViolationException catch (error) {
    return ViolacaoRegra(codigo: 'semana.regra', mensagem: error.message);
  } on SemanaRepositoryException catch (error) {
    return FalhaTecnica(codigo: 'semana.falha', mensagem: error.message);
  }
}
