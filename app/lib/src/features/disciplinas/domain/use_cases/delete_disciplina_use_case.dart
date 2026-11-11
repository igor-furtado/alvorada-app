import '../../../../core/domain/resultado.dart';
import '../repositories/disciplinas_repository.dart';
import 'disciplinas_resultado_codes.dart';
import 'disciplinas_use_case_support.dart';

class DeleteDisciplinaUseCase {
  const DeleteDisciplinaUseCase(this._repository);

  final DisciplinasRepository _repository;

  Future<Resultado<void>> call(String id) => executarDisciplinasUseCase(
    operacao: () => _repository.deleteDisciplina(id),
    codigoFalha: DisciplinasResultadoCodes.exclusaoFalhou,
  );
}
