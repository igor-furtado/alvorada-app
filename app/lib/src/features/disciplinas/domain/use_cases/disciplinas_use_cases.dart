import '../repositories/disciplinas_repository.dart';
import 'create_disciplina_use_case.dart';
import 'create_subtopico_use_case.dart';
import 'create_topico_use_case.dart';
import 'delete_disciplina_use_case.dart';
import 'delete_subtopico_use_case.dart';
import 'delete_topico_use_case.dart';
import 'get_disciplinas_use_case.dart';
import 'update_disciplina_use_case.dart';
import 'update_subtopico_use_case.dart';
import 'update_topico_use_case.dart';

class DisciplinasUseCases {
  DisciplinasUseCases(DisciplinasRepository repository)
    : getDisciplinas = GetDisciplinasUseCase(repository),
      createDisciplina = CreateDisciplinaUseCase(repository),
      updateDisciplina = UpdateDisciplinaUseCase(repository),
      deleteDisciplina = DeleteDisciplinaUseCase(repository),
      createTopico = CreateTopicoUseCase(repository),
      updateTopico = UpdateTopicoUseCase(repository),
      deleteTopico = DeleteTopicoUseCase(repository),
      createSubtopico = CreateSubtopicoUseCase(repository),
      updateSubtopico = UpdateSubtopicoUseCase(repository),
      deleteSubtopico = DeleteSubtopicoUseCase(repository);

  final GetDisciplinasUseCase getDisciplinas;
  final CreateDisciplinaUseCase createDisciplina;
  final UpdateDisciplinaUseCase updateDisciplina;
  final DeleteDisciplinaUseCase deleteDisciplina;
  final CreateTopicoUseCase createTopico;
  final UpdateTopicoUseCase updateTopico;
  final DeleteTopicoUseCase deleteTopico;
  final CreateSubtopicoUseCase createSubtopico;
  final UpdateSubtopicoUseCase updateSubtopico;
  final DeleteSubtopicoUseCase deleteSubtopico;
}
