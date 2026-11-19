import 'package:estudos_app/core/result.dart';

import '../repositories/disciplinas_repository.dart';
import 'disciplinas_resultado_codes.dart';
import 'disciplinas_use_case_support.dart';

class ReorderDisciplinasUseCase {
  const ReorderDisciplinasUseCase(this._repository);

  final DisciplinasRepository _repository;

  Future<Resultado<void>> call(List<String> disciplinaIds) => executarDisciplinasUseCase(
    operacao: () => _repository.reorderDisciplinas(List.unmodifiable(disciplinaIds)),
    codigoFalha: DisciplinasResultadoCodes.disciplinaReordenacaoFalhou,
  );
}
