import '../../../../core/domain/resultado.dart';
import '../repositories/disciplinas_repository.dart';
import 'disciplinas_resultado_codes.dart';
import 'disciplinas_use_case_support.dart';

class CreateSubtopicoUseCase {
  const CreateSubtopicoUseCase(this._repository);

  final DisciplinasRepository _repository;

  Future<Resultado<void>> call({
    required String topicId,
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
      operacao: () => _repository.createSubtopico(
        topicId: topicId,
        name: normalizedName,
      ),
      codigoFalha: DisciplinasResultadoCodes.subtopicoCriacaoFalhou,
    );
  }
}
