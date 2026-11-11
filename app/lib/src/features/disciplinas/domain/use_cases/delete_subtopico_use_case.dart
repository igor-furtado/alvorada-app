import '../../../../core/domain/resultado.dart';
import '../repositories/disciplinas_repository.dart';
import 'disciplinas_resultado_codes.dart';
import 'disciplinas_use_case_support.dart';

class DeleteSubtopicoUseCase {
  const DeleteSubtopicoUseCase(this._repository);

  final DisciplinasRepository _repository;

  Future<Resultado<void>> call(String subtopicId) => executarDisciplinasUseCase(
    operacao: () => _repository.deleteSubtopico(subtopicId),
    codigoFalha: DisciplinasResultadoCodes.subtopicoExclusaoFalhou,
  );
}
