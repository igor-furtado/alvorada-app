import 'package:estudos_app/core/result.dart';

import '../models/disciplina_input.dart';
import '../repositories/disciplinas_repository.dart';
import 'disciplinas_resultado_codes.dart';
import 'disciplinas_use_case_support.dart';

class ReplaceTopicosUseCase {
  const ReplaceTopicosUseCase(this._repository);

  final DisciplinasRepository _repository;

  Future<Resultado<void>> call({
    required String disciplineId,
    required List<ReplaceTopicoInput> topics,
  }) {
    final normalized = <ReplaceTopicoInput>[];
    final names = <String>{};
    for (final topic in topics) {
      final name = topic.name.trim();
      final invalidName = validarNome<void>(
        name,
        nomeConceito: 'o Tópico',
        codigoObrigatorio: DisciplinasResultadoCodes.topicoNomeObrigatorio,
        codigoMuitoLongo: DisciplinasResultadoCodes.topicoNomeMuitoLongo,
      );
      if (invalidName != null) return Future.value(invalidName);
      if (!names.add(name.toLowerCase())) {
        return Future.value(
          const ViolacaoRegra(
            codigo: DisciplinasResultadoCodes.topicoCriacaoFalhou,
            mensagem: 'Não repita o mesmo Tópico.',
          ),
        );
      }
      normalized.add(ReplaceTopicoInput(id: topic.id, name: name));
    }
    return executarDisciplinasUseCase(
      operacao: () => _repository.replaceTopicos(
        disciplineId: disciplineId,
        topics: normalized,
      ),
      codigoFalha: DisciplinasResultadoCodes.topicoCriacaoFalhou,
    );
  }
}
