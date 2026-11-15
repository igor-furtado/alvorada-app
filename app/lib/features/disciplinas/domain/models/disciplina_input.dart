import 'disciplina.dart';

class CreateDisciplinaInput {
  const CreateDisciplinaInput({
    required this.name,
    this.difficulty = DificuldadeDisciplina.medium,
    this.color = '#E8742A',
  });

  final String name;
  final DificuldadeDisciplina difficulty;
  final String color;
}

class UpdateDisciplinaInput {
  const UpdateDisciplinaInput({this.name, this.difficulty, this.color});

  final String? name;
  final DificuldadeDisciplina? difficulty;
  final String? color;

  bool get hasChanges => name != null || difficulty != null || color != null;
}
