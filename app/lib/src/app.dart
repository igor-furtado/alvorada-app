import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/brand/app_brand.dart';
import 'core/presentation/app_shell.dart';
import 'core/theme/app_theme.dart';
import 'features/errors/presentation/error_notebook_page.dart';
import 'features/horizons/presentation/discipline_details_page.dart';
import 'features/horizons/presentation/horizon_details_page.dart';
import 'features/horizons/presentation/horizon_view_data.dart';
import 'features/horizons/presentation/horizons_page.dart';
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
              path: '/horizontes',
              builder: (context, state) => const HorizonsPage(),
              routes: [
                GoRoute(
                  path: ':horizonId',
                  builder: (context, state) => HorizonDetailsPage(
                    horizonId: state.pathParameters['horizonId']!,
                    horizonOverride: state.extra is HorizonViewData ? state.extra! as HorizonViewData : null,
                  ),
                  routes: [
                    GoRoute(
                      path: 'disciplinas/:disciplineName',
                      builder: (context, state) => DisciplineDetailsPage(
                        horizonId: state.pathParameters['horizonId']!,
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
          routes: [GoRoute(path: '/revisoes', builder: (context, state) => const ReviewsPage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/caderno-de-erros', builder: (context, state) => const ErrorNotebookPage())],
        ),
      ],
    ),
  ],
);

class EstudosApp extends StatelessWidget {
  const EstudosApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: AppBrand.applicationTitle,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ThemeMode.system,
    restorationScopeId: 'application',
    routerConfig: _router,
  );
}
