import '../repositories/concursos_repository.dart';
import 'archive_concurso_use_case.dart';
import 'create_concurso_use_case.dart';
import 'delete_concurso_use_case.dart';
import 'get_concurso_use_case.dart';
import 'get_concursos_use_case.dart';
import 'restore_concurso_use_case.dart';
import 'set_concurso_prioritario_use_case.dart';
import 'update_concurso_use_case.dart';

class ConcursosUseCases {
  ConcursosUseCases(ConcursosRepository repository)
    : getConcurso = GetConcursoUseCase(repository),
      getConcursos = GetConcursosUseCase(repository),
      createConcurso = CreateConcursoUseCase(repository),
      updateConcurso = UpdateConcursoUseCase(repository),
      setConcursoPrioritario = SetConcursoPrioritarioUseCase(repository),
      archiveConcurso = ArchiveConcursoUseCase(repository),
      restoreConcurso = RestoreConcursoUseCase(repository),
      deleteConcurso = DeleteConcursoUseCase(repository);

  final GetConcursoUseCase getConcurso;
  final GetConcursosUseCase getConcursos;
  final CreateConcursoUseCase createConcurso;
  final UpdateConcursoUseCase updateConcurso;
  final SetConcursoPrioritarioUseCase setConcursoPrioritario;
  final ArchiveConcursoUseCase archiveConcurso;
  final RestoreConcursoUseCase restoreConcurso;
  final DeleteConcursoUseCase deleteConcurso;
}
