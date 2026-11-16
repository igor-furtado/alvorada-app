import 'package:estudos_app/core/result.dart';

import '../repositories/disciplinas_repository.dart';
import 'disciplinas_resultado_codes.dart';
import 'disciplinas_use_case_support.dart';

class ReorderTopicosUseCase {
  const ReorderTopicosUseCase(this._repository);

  final DisciplinasRepository _repository;

  Future<Resultado<void>> call({
    required String disciplineId,
    required List<String> topicIds,
  }) => executarDisciplinasUseCase(
    operacao: () => _repository.reorderTopicos(
      disciplineId: disciplineId,
      topicIds: List.unmodifiable(topicIds),
    ),
    codigoFalha: DisciplinasResultadoCodes.topicoReordenacaoFalhou,
  );
}
