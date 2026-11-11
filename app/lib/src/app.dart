import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'core/brand/app_brand.dart';
import 'core/presentation/app_shell.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_mode.dart';
import 'features/administration/presentation/administration_page.dart';
import 'features/concursos/data/repositories/api_concursos_repository.dart';
import 'features/concursos/data/services/concursos_api_service.dart';
import 'features/concursos/domain/repositories/concursos_repository.dart';
import 'features/concursos/domain/use_cases/concursos_use_cases.dart';
import 'features/concursos/presentation/concurso_details_page.dart';
import 'features/concursos/presentation/concursos_page.dart';
import 'features/design_system/presentation/component_catalog_page.dart';
import 'features/disciplinas/data/repositories/api_disciplinas_repository.dart';
import 'features/disciplinas/data/services/disciplinas_api_service.dart';
import 'features/disciplinas/domain/repositories/disciplinas_repository.dart';
import 'features/disciplinas/domain/use_cases/disciplinas_use_cases.dart';
import 'features/disciplinas/presentation/disciplinas_list/disciplinas_list_state.dart';
import 'features/disciplinas/presentation/disciplinas_page.dart';

final _router = GoRouter(
  restorationScopeId: 'router',
  initialLocation: '/concursos',
  routes: [
    GoRoute(path: '/', redirect: (context, state) => '/concursos'),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/concursos',
              builder: (context, state) => const ConcursosPage(),
              routes: [
                GoRoute(
                  path: ':concursoId',
                  builder: (context, state) => ConcursoDetailsPage(
                    concursoId: state.pathParameters['concursoId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/disciplinas',
              builder: (context, state) => DisciplinasPage(
                initialQuery: state.uri.queryParameters['busca'] ?? '',
                initialOrder: state.uri.queryParameters['ordem'] == 'alfabetica'
                    ? DisciplinasListOrder.alphabetical
                    : DisciplinasListOrder.catalog,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/administracao',
              builder: (context, state) => const AdministrationPage(),
              routes: [
                GoRoute(
                  path: 'componentes',
                  builder: (context, state) => const ComponentCatalogPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class EstudosApp extends StatefulWidget {
  const EstudosApp({this.disciplinasRepository, this.concursosRepository, super.key});

  final DisciplinasRepository? disciplinasRepository;
  final ConcursosRepository? concursosRepository;

  @override
  State<EstudosApp> createState() => _EstudosAppState();
}

class _EstudosAppState extends State<EstudosApp> {
  http.Client? _client;
  late final DisciplinasRepository _disciplinasRepository;
  late final DisciplinasUseCases _disciplinasUseCases;
  late final ConcursosRepository _concursosRepository;
  late final ConcursosUseCases _concursosUseCases;
  late final AppThemeModeController _themeModeController;

  @override
  void initState() {
    super.initState();
    _themeModeController = AppThemeModeController();
    if (widget.disciplinasRepository == null || widget.concursosRepository == null) {
      _client = http.Client();
    }
    _disciplinasRepository = widget.disciplinasRepository ?? ApiDisciplinasRepository(DisciplinasApiService(_client!));
    _disciplinasUseCases = DisciplinasUseCases(_disciplinasRepository);
    _concursosRepository = widget.concursosRepository ?? ApiConcursosRepository(ConcursosApiService(_client!));
    _concursosUseCases = ConcursosUseCases(_concursosRepository);
  }

  @override
  void dispose() {
    _client?.close();
    _themeModeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppThemeModeScope(
    controller: _themeModeController,
    child: MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DisciplinasUseCases>.value(value: _disciplinasUseCases),
        RepositoryProvider<ConcursosUseCases>.value(value: _concursosUseCases),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeModeController,
        builder: (context, themeMode, child) => MaterialApp.router(
          title: AppBrand.applicationTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          restorationScopeId: 'application',
          routerConfig: _router,
        ),
      ),
    ),
  );
}
