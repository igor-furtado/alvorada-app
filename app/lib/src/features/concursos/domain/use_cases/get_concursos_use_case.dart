import '../../../../core/domain/resultado.dart';
import '../models/concurso.dart';
import '../repositories/concursos_repository.dart';
import 'concursos_resultado_codes.dart';
import 'concursos_use_case_support.dart';

class GetConcursosUseCase {
  const GetConcursosUseCase(this._repository);

  final ConcursosRepository _repository;

  Future<Resultado<List<Concurso>>> call({bool forceRefresh = false}) => executarConcursosUseCase(
    operacao: () => _repository.getConcursos(
      forceRefresh: forceRefresh,
    ),
    codigoFalha: ConcursosResultadoCodes.carregamentoFalhou,
  );
}
