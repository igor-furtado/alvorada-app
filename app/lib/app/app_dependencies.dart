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

/// Composition root dos serviços compartilhados pela aplicação.
final class AppDependencies {
  AppDependencies._({
    required this.disciplinas,
    required this.concursos,
    this._ownedClient,
  });

  factory AppDependencies.production() {
    final client = http.Client();
    return AppDependencies._(
      disciplinas: DisciplinasUseCases(ApiDisciplinasRepository(DisciplinasApiService(client))),
      concursos: ConcursosUseCases(ApiConcursosRepository(ConcursosApiService(client))),
      ownedClient: client,
    );
  }

  factory AppDependencies.fromRepositories({
    required DisciplinasRepository disciplinas,
    required ConcursosRepository concursos,
  }) => AppDependencies._(
    disciplinas: DisciplinasUseCases(disciplinas),
    concursos: ConcursosUseCases(concursos),
  );

  final DisciplinasUseCases disciplinas;
  final ConcursosUseCases concursos;
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
    ],
    child: child,
  );
}
