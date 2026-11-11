import '../../../../core/domain/resultado.dart';
import '../repositories/disciplinas_repository.dart';
import 'disciplinas_resultado_codes.dart';
import 'disciplinas_use_case_support.dart';

class UpdateTopicoUseCase {
  const UpdateTopicoUseCase(this._repository);

  final DisciplinasRepository _repository;

  Future<Resultado<void>> call({
    required String topicId,
    required String name,
  }) {
    final normalizedName = name.trim();
    final invalidName = validarNome<void>(
      normalizedName,
      nomeConceito: 'o Tópico',
      codigoObrigatorio: DisciplinasResultadoCodes.topicoNomeObrigatorio,
      codigoMuitoLongo: DisciplinasResultadoCodes.topicoNomeMuitoLongo,
    );
    if (invalidName != null) return Future.value(invalidName);
    return executarDisciplinasUseCase(
      operacao: () => _repository.updateTopico(
        topicId: topicId,
        name: normalizedName,
      ),
      codigoFalha: DisciplinasResultadoCodes.topicoAtualizacaoFalhou,
    );
  }
}
