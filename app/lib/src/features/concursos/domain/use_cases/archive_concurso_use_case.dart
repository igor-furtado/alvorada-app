import '../../../../core/domain/resultado.dart';
import '../repositories/concursos_repository.dart';
import 'concursos_resultado_codes.dart';
import 'concursos_use_case_support.dart';

class ArchiveConcursoUseCase {
  const ArchiveConcursoUseCase(this._repository);

  final ConcursosRepository _repository;

  Future<Resultado<void>> call(String id) => executarConcursosUseCase(
    operacao: () => _repository.archiveConcurso(id),
    codigoFalha: ConcursosResultadoCodes.arquivamentoFalhou,
  );
}
