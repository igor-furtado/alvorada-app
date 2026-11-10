import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'core/brand/app_brand.dart';
import 'core/presentation/app_shell.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_mode.dart';
import 'features/administration/presentation/administration_page.dart';
import 'features/contests/presentation/contest_details_page.dart';
import 'features/contests/presentation/contest_view_data.dart';
import 'features/contests/presentation/contests_page.dart';
import 'features/contests/presentation/discipline_details_page.dart';
import 'features/design_system/presentation/component_catalog_page.dart';
import 'features/disciplinas/data/repositories/api_disciplinas_repository.dart';
import 'features/disciplinas/data/services/disciplinas_api_service.dart';
import 'features/disciplinas/domain/repositories/disciplinas_repository.dart';
import 'features/disciplinas/presentation/bloc/disciplinas_bloc.dart';
import 'features/disciplinas/presentation/bloc/disciplinas_event.dart';
import 'features/disciplinas/presentation/pages/disciplinas_page.dart';
import 'features/errors/presentation/error_notebook_page.dart';
import 'features/reviews/presentation/reviews_page.dart';
import 'features/today/presentation/today_page.dart';
import 'features/week/presentation/week_page.dart';

final _router = GoRouter(
  restorationScopeId: 'router',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/', builder: (context, state) => const TodayPage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/semana', builder: (context, state) => const WeekPage())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/concursos',
              builder: (context, state) => const ContestsPage(),
              routes: [
                GoRoute(
                  path: ':contestId',
                  builder: (context, state) => ContestDetailsPage(
                    contestId: state.pathParameters['contestId']!,
                    contestOverride: state.extra is ContestViewData ? state.extra! as ContestViewData : null,
                  ),
                  routes: [
                    GoRoute(
                      path: 'disciplinas/:disciplineName',
                      builder: (context, state) => DisciplineDetailsPage(
                        contestId: state.pathParameters['contestId']!,
                        disciplineName: state.pathParameters['disciplineName']!,
                        arguments: state.extra is DisciplineDetailsArguments
                            ? state.extra! as DisciplineDetailsArguments
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/disciplinas',
              builder: (context, state) => BlocProvider(
                create: (context) => DisciplinasBloc(
                  repository: context.read<DisciplinasRepository>(),
                )..add(const LoadDisciplinasRequested()),
                child: const DisciplinasPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/revisoes', builder: (context, state) => const ReviewsPage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/caderno-de-erros', builder: (context, state) => const ErrorNotebookPage())],
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
  const EstudosApp({this.disciplinasRepository, super.key});

  final DisciplinasRepository? disciplinasRepository;

  @override
  State<EstudosApp> createState() => _EstudosAppState();
}

class _EstudosAppState extends State<EstudosApp> {
  http.Client? _client;
  late final DisciplinasRepository _disciplinasRepository;
  late final AppThemeModeController _themeModeController;

  @override
  void initState() {
    super.initState();
    _themeModeController = AppThemeModeController();
    final injectedRepository = widget.disciplinasRepository;
    if (injectedRepository != null) {
      _disciplinasRepository = injectedRepository;
    } else {
      _client = http.Client();
      _disciplinasRepository = ApiDisciplinasRepository(DisciplinasApiService(_client!));
    }
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
    child: RepositoryProvider<DisciplinasRepository>.value(
      value: _disciplinasRepository,
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
