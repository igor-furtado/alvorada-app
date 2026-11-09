import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/brand/app_brand.dart';
import 'core/presentation/app_shell.dart';
import 'core/theme/app_theme.dart';
import 'features/contests/presentation/contest_details_page.dart';
import 'features/contests/presentation/contest_view_data.dart';
import 'features/contests/presentation/contests_page.dart';
import 'features/contests/presentation/discipline_details_page.dart';
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
          routes: [GoRoute(path: '/revisoes', builder: (context, state) => const ReviewsPage())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/caderno-de-erros', builder: (context, state) => const ErrorNotebookPage())],
        ),
      ],
    ),
    GoRoute(path: '/horizontes', redirect: (context, state) => '/concursos'),
    GoRoute(
      path: '/horizontes/:contestId',
      redirect: (context, state) {
        final contestId = Uri.encodeComponent(state.pathParameters['contestId']!);
        return '/concursos/$contestId';
      },
    ),
    GoRoute(
      path: '/horizontes/:contestId/disciplinas/:disciplineName',
      redirect: (context, state) {
        final contestId = Uri.encodeComponent(state.pathParameters['contestId']!);
        final disciplineName = Uri.encodeComponent(state.pathParameters['disciplineName']!);
        return '/concursos/$contestId/disciplinas/$disciplineName';
      },
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
