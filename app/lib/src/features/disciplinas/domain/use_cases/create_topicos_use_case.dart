import '../../../../core/domain/resultado.dart';
import '../repositories/disciplinas_repository.dart';
import 'disciplinas_resultado_codes.dart';
import 'disciplinas_use_case_support.dart';

class CreateTopicosUseCase {
  const CreateTopicosUseCase(this._repository);

  final DisciplinasRepository _repository;

  Future<Resultado<void>> call({
    required String disciplineId,
    required List<String> names,
  }) {
    final normalizedNames = names.map((name) => name.trim()).where((name) => name.isNotEmpty).toList(growable: false);
    if (normalizedNames.isEmpty) {
      return Future.value(
        const ViolacaoRegra(
          codigo: DisciplinasResultadoCodes.topicoNomeObrigatorio,
          mensagem: 'Informe ao menos um Tópico.',
        ),
      );
    }
    for (final name in normalizedNames) {
      final invalidName = validarNome<void>(
        name,
        nomeConceito: 'o Tópico',
        codigoObrigatorio: DisciplinasResultadoCodes.topicoNomeObrigatorio,
        codigoMuitoLongo: DisciplinasResultadoCodes.topicoNomeMuitoLongo,
      );
      if (invalidName != null) return Future.value(invalidName);
    }
    return executarDisciplinasUseCase(
      operacao: () => _repository.createTopicos(
        disciplineId: disciplineId,
        names: normalizedNames,
      ),
      codigoFalha: DisciplinasResultadoCodes.topicoCriacaoFalhou,
    );
  }
}
