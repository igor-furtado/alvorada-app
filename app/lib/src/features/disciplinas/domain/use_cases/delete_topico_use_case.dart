import '../../../../core/domain/resultado.dart';
import '../repositories/disciplinas_repository.dart';
import 'disciplinas_resultado_codes.dart';
import 'disciplinas_use_case_support.dart';

class DeleteTopicoUseCase {
  const DeleteTopicoUseCase(this._repository);

  final DisciplinasRepository _repository;

  Future<Resultado<void>> call(String topicId) => executarDisciplinasUseCase(
    operacao: () => _repository.deleteTopico(topicId),
    codigoFalha: DisciplinasResultadoCodes.topicoExclusaoFalhou,
  );
}
