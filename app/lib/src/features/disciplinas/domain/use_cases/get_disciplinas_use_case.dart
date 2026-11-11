import '../../../../core/domain/resultado.dart';
import '../models/disciplina.dart';
import '../repositories/disciplinas_repository.dart';
import 'disciplinas_resultado_codes.dart';
import 'disciplinas_use_case_support.dart';

class GetDisciplinasUseCase {
  const GetDisciplinasUseCase(this._repository);

  final DisciplinasRepository _repository;

  Future<Resultado<List<Disciplina>>> call({bool forceRefresh = false}) => executarDisciplinasUseCase(
    operacao: () => _repository.getDisciplinas(
      forceRefresh: forceRefresh,
    ),
    codigoFalha: DisciplinasResultadoCodes.carregamentoFalhou,
  );
}
