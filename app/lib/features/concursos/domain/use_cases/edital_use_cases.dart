import 'package:estudos_app/core/result.dart';

import '../repositories/concursos_repository.dart';
import 'concursos_resultado_codes.dart';
import 'concursos_use_case_support.dart';

class EditalUseCases {
  const EditalUseCases(this._repository);

  final ConcursosRepository _repository;

  Future<Resultado<void>> addDisciplina({
    required String concursoId,
    required String disciplinaId,
  }) => executarConcursosUseCase(
    operacao: () => _repository.addDisciplinaToEdital(
      concursoId: concursoId,
      disciplinaId: disciplinaId,
    ),
    codigoFalha: ConcursosResultadoCodes.editalAtualizacaoFalhou,
  );

  Future<Resultado<void>> addTopico({
    required String concursoId,
    required String topicoId,
  }) => executarConcursosUseCase(
    operacao: () => _repository.addTopicoToEdital(
      concursoId: concursoId,
      topicoId: topicoId,
    ),
    codigoFalha: ConcursosResultadoCodes.editalAtualizacaoFalhou,
  );

  Future<Resultado<void>> updateDisciplinaPeso({
    required String concursoId,
    required String disciplinaId,
    required double peso,
  }) => executarConcursosUseCase(
    operacao: () => _repository.updateDisciplinaPeso(
      concursoId: concursoId,
      disciplinaId: disciplinaId,
      peso: peso,
    ),
    codigoFalha: ConcursosResultadoCodes.editalAtualizacaoFalhou,
  );

  Future<Resultado<void>> removeTopico({
    required String concursoId,
    required String topicoId,
  }) => executarConcursosUseCase(
    operacao: () => _repository.removeTopicoFromEdital(
      concursoId: concursoId,
      topicoId: topicoId,
    ),
    codigoFalha: ConcursosResultadoCodes.editalAtualizacaoFalhou,
  );
}
