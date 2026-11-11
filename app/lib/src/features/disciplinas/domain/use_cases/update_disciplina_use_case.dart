import '../../../../core/domain/resultado.dart';
import '../models/disciplina_input.dart';
import '../repositories/disciplinas_repository.dart';
import 'disciplinas_resultado_codes.dart';
import 'disciplinas_use_case_support.dart';

class UpdateDisciplinaUseCase {
  const UpdateDisciplinaUseCase(this._repository);

  final DisciplinasRepository _repository;

  Future<Resultado<void>> call(
    String id,
    UpdateDisciplinaInput input,
  ) {
    final name = input.name?.trim();
    if (name != null) {
      final invalidName = validarNome<void>(
        name,
        nomeConceito: 'a Disciplina',
        codigoObrigatorio: DisciplinasResultadoCodes.disciplinaNomeObrigatorio,
        codigoMuitoLongo: DisciplinasResultadoCodes.disciplinaNomeMuitoLongo,
      );
      if (invalidName != null) return Future.value(invalidName);
    }
    final color = input.color;
    if (color != null && !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(color)) {
      return Future.value(
        const ViolacaoRegra(
          codigo: DisciplinasResultadoCodes.disciplinaCorInvalida,
          mensagem: 'A cor da Disciplina deve estar no formato hexadecimal #RRGGBB.',
        ),
      );
    }
    return executarDisciplinasUseCase(
      operacao: () => _repository.updateDisciplina(
        id,
        UpdateDisciplinaInput(
          name: name,
          difficulty: input.difficulty,
          color: color,
        ),
      ),
      codigoFalha: DisciplinasResultadoCodes.atualizacaoFalhou,
    );
  }
}
