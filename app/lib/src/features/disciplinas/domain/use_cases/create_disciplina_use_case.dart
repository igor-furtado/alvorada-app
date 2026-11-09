import '../models/disciplina.dart';
import '../models/disciplina_input.dart';
import '../repositories/disciplinas_repository.dart';

class CreateDisciplinaUseCase {
  const CreateDisciplinaUseCase(this._repository);

  final DisciplinasRepository _repository;

  Future<Disciplina> call(CreateDisciplinaInput input) {
    final name = input.name.trim();
    if (name.isEmpty) {
      throw const DisciplinaInputException('Informe um nome para a Disciplina.');
    }
    if (name.runes.length > 120) {
      throw const DisciplinaInputException('O nome da Disciplina deve ter no máximo 120 caracteres.');
    }
    if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(input.color)) {
      throw const DisciplinaInputException('A cor da Disciplina deve estar no formato hexadecimal #RRGGBB.');
    }
    return _repository.createDisciplina(
      CreateDisciplinaInput(name: name, difficulty: input.difficulty, color: input.color),
    );
  }
}

class DisciplinaInputException implements Exception {
  const DisciplinaInputException(this.message);

  final String message;

  @override
  String toString() => message;
}
