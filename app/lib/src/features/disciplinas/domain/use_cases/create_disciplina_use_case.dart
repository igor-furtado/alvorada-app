import '../../../../core/domain/resultado.dart';
import '../models/disciplina.dart';
import '../models/disciplina_input.dart';
import '../repositories/disciplinas_repository.dart';
import 'disciplinas_resultado_codes.dart';
import 'disciplinas_use_case_support.dart';

class CreateDisciplinaUseCase {
  const CreateDisciplinaUseCase(this._repository);

  final DisciplinasRepository _repository;

  Future<Resultado<Disciplina>> call(CreateDisciplinaInput input) {
    final name = input.name.trim();
    final invalidName = validarNome<Disciplina>(
      name,
      nomeConceito: 'a Disciplina',
      codigoObrigatorio: DisciplinasResultadoCodes.disciplinaNomeObrigatorio,
      codigoMuitoLongo: DisciplinasResultadoCodes.disciplinaNomeMuitoLongo,
    );
    if (invalidName != null) return Future.value(invalidName);
    if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(input.color)) {
      return Future.value(
        const ViolacaoRegra(
          codigo: DisciplinasResultadoCodes.disciplinaCorInvalida,
          mensagem: 'A cor da Disciplina deve estar no formato hexadecimal #RRGGBB.',
        ),
      );
    }
    return executarDisciplinasUseCase(
      operacao: () => _repository.createDisciplina(
        CreateDisciplinaInput(
          name: name,
          difficulty: input.difficulty,
          color: input.color,
        ),
      ),
      codigoFalha: DisciplinasResultadoCodes.criacaoFalhou,
    );
  }
}
