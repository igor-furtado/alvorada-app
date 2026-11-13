import '../repositories/disciplinas_repository.dart';
import 'create_disciplina_use_case.dart';
import 'create_topicos_use_case.dart';
import 'delete_disciplina_use_case.dart';
import 'delete_topico_use_case.dart';
import 'get_disciplinas_use_case.dart';
import 'update_disciplina_use_case.dart';
import 'update_topico_use_case.dart';

class DisciplinasUseCases {
  DisciplinasUseCases(DisciplinasRepository repository)
    : getDisciplinas = GetDisciplinasUseCase(repository),
      createDisciplina = CreateDisciplinaUseCase(repository),
      updateDisciplina = UpdateDisciplinaUseCase(repository),
      deleteDisciplina = DeleteDisciplinaUseCase(repository),
      createTopicos = CreateTopicosUseCase(repository),
      updateTopico = UpdateTopicoUseCase(repository),
      deleteTopico = DeleteTopicoUseCase(repository);

  final GetDisciplinasUseCase getDisciplinas;
  final CreateDisciplinaUseCase createDisciplina;
  final UpdateDisciplinaUseCase updateDisciplina;
  final DeleteDisciplinaUseCase deleteDisciplina;
  final CreateTopicosUseCase createTopicos;
  final UpdateTopicoUseCase updateTopico;
  final DeleteTopicoUseCase deleteTopico;
}
