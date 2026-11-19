import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../features/concursos/data/repositories/api_concursos_repository.dart';
import '../features/concursos/data/services/concursos_api_service.dart';
import '../features/concursos/domain/repositories/concursos_repository.dart';
import '../features/concursos/domain/use_cases/concursos_use_cases.dart';
import '../features/disciplinas/data/repositories/api_disciplinas_repository.dart';
import '../features/disciplinas/data/services/disciplinas_api_service.dart';
import '../features/disciplinas/domain/repositories/disciplinas_repository.dart';
import '../features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import '../features/semana/data/repositories/api_semana_repository.dart';
import '../features/semana/data/services/semana_api_service.dart';
import '../features/semana/domain/models/planejamento_semanal.dart';
import '../features/semana/domain/repositories/semana_repository.dart';
import '../features/semana/domain/use_cases/semana_use_cases.dart';

/// Composition root dos serviços compartilhados pela aplicação.
final class AppDependencies {
  AppDependencies._({
    required this.disciplinas,
    required this.concursos,
    required this.semana,
    this._ownedClient,
  });

  factory AppDependencies.production() {
    final client = http.Client();
    return AppDependencies._(
      disciplinas: DisciplinasUseCases(ApiDisciplinasRepository(DisciplinasApiService(client))),
      concursos: ConcursosUseCases(ApiConcursosRepository(ConcursosApiService(client))),
      semana: SemanaUseCases(ApiSemanaRepository(SemanaApiService(client))),
      ownedClient: client,
    );
  }

  factory AppDependencies.fromRepositories({
    required DisciplinasRepository disciplinas,
    required ConcursosRepository concursos,
    SemanaRepository? semana,
  }) => AppDependencies._(
    disciplinas: DisciplinasUseCases(disciplinas),
    concursos: ConcursosUseCases(concursos),
    semana: SemanaUseCases(semana ?? const _UnavailableSemanaRepository()),
  );

  final DisciplinasUseCases disciplinas;
  final ConcursosUseCases concursos;
  final SemanaUseCases semana;
  final http.Client? _ownedClient;

  void dispose() => _ownedClient?.close();
}

class AppDependenciesProvider extends StatelessWidget {
  const AppDependenciesProvider({required this.dependencies, required this.child, super.key});

  final AppDependencies dependencies;
  final Widget child;

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<DisciplinasUseCases>.value(value: dependencies.disciplinas),
      RepositoryProvider<ConcursosUseCases>.value(value: dependencies.concursos),
      RepositoryProvider<SemanaUseCases>.value(value: dependencies.semana),
    ],
    child: child,
  );
}

class _UnavailableSemanaRepository implements SemanaRepository {
  const _UnavailableSemanaRepository();

  Never _unavailable() => throw const SemanaRepositoryException('Repositório da Semana não configurado.');

  @override
  Future<PlanejamentoSemanal> getPlanejamento({required DateTime inicio, required DateTime fim}) async =>
      _unavailable();

  @override
  Future<void> atualizarProgresso({
    required String concursoId,
    required String topicoId,
    required ProgressoTopicoInput input,
  }) async => _unavailable();

  @override
  Future<void> concluirRevisao(String revisaoId) async => _unavailable();

  @override
  Future<void> moverRevisao({required String revisaoId, required DateTime data, int posicaoDia = 0}) async =>
      _unavailable();

  @override
  Future<void> planejarTopico({
    required String concursoId,
    required String topicoId,
    required DateTime data,
    int posicaoDia = 0,
  }) async => _unavailable();

  @override
  Future<void> registrarQuestao({
    required String concursoId,
    required String topicoId,
    required ResultadoQuestao resultado,
  }) async => _unavailable();

  @override
  Future<void> substituirRevisoes({
    required String concursoId,
    required String topicoId,
    required Set<int> intervalosDias,
  }) async => _unavailable();
}
