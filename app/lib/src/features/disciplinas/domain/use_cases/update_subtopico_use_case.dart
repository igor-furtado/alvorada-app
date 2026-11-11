import '../../../../core/domain/resultado.dart';
import '../repositories/disciplinas_repository.dart';
import 'disciplinas_resultado_codes.dart';
import 'disciplinas_use_case_support.dart';

class UpdateSubtopicoUseCase {
  const UpdateSubtopicoUseCase(this._repository);

  final DisciplinasRepository _repository;

  Future<Resultado<void>> call({
    required String subtopicId,
    required String name,
  }) {
    final normalizedName = name.trim();
    final invalidName = validarNome<void>(
      normalizedName,
      nomeConceito: 'o Subtópico',
      codigoObrigatorio: DisciplinasResultadoCodes.subtopicoNomeObrigatorio,
      codigoMuitoLongo: DisciplinasResultadoCodes.subtopicoNomeMuitoLongo,
    );
    if (invalidName != null) return Future.value(invalidName);
    return executarDisciplinasUseCase(
      operacao: () => _repository.updateSubtopico(
        subtopicId: subtopicId,
        name: normalizedName,
      ),
      codigoFalha: DisciplinasResultadoCodes.subtopicoAtualizacaoFalhou,
    );
  }
}
