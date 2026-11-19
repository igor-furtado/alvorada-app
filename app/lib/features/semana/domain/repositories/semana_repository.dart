import '../models/planejamento_semanal.dart';

abstract interface class SemanaRepository {
  Future<PlanejamentoSemanal> getPlanejamento({
    required DateTime inicio,
    required DateTime fim,
  });

  Future<void> planejarTopico({
    required String concursoId,
    required String topicoId,
    required DateTime data,
    int posicaoDia = 0,
  });

  Future<void> atualizarProgresso({
    required String concursoId,
    required String topicoId,
    required ProgressoTopicoInput input,
  });

  Future<void> registrarQuestao({
    required String concursoId,
    required String topicoId,
    required ResultadoQuestao resultado,
  });

  Future<void> substituirRevisoes({
    required String concursoId,
    required String topicoId,
    required Set<int> intervalosDias,
  });

  Future<void> moverRevisao({
    required String revisaoId,
    required DateTime data,
    int posicaoDia = 0,
  });

  Future<void> concluirRevisao(String revisaoId);
}

class SemanaRepositoryException implements Exception {
  const SemanaRepositoryException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class SemanaRuleViolationException extends SemanaRepositoryException {
  const SemanaRuleViolationException(super.message, [super.cause]);
}
