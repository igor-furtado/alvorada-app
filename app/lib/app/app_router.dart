import 'package:go_router/go_router.dart';

import '../features/concursos/presentation/concurso_details/concurso_details_page.dart';
import '../features/concursos/presentation/concursos_page.dart';
import '../features/disciplinas/presentation/disciplinas_page.dart';
import '../features/semana/presentation/semana/semana_page.dart';
import 'app_shell.dart';

abstract final class AppRoutes {
  static const concursos = '/concursos';
  static const disciplinas = '/disciplinas';
  static const semana = '/semana';

  static String concurso(String id) => '$concursos/$id';
}

GoRouter createAppRouter({String initialLocation = AppRoutes.concursos}) => GoRouter(
  restorationScopeId: 'router',
  initialLocation: initialLocation,
  routes: [
    GoRoute(path: '/', redirect: (context, state) => AppRoutes.concursos),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.concursos,
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
              path: AppRoutes.disciplinas,
              builder: (context, state) => DisciplinasPage(
                initialQuery: state.uri.queryParameters['busca'] ?? '',
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.semana,
              builder: (context, state) => const SemanaPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
