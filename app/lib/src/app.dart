import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/horizons/presentation/horizons_page.dart';
import 'features/reviews/presentation/reviews_page.dart';
import 'features/today/presentation/today_page.dart';
import 'features/week/presentation/week_page.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const TodayPage()),
    GoRoute(path: '/semana', builder: (context, state) => const WeekPage()),
    GoRoute(
      path: '/horizontes',
      builder: (context, state) => const HorizonsPage(),
    ),
    GoRoute(
      path: '/revisoes',
      builder: (context, state) => const ReviewsPage(),
    ),
  ],
);

class EstudosApp extends StatelessWidget {
  const EstudosApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Alvorada.app — Cada manhã conta.',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: ThemeMode.system,
    routerConfig: _router,
  );
}
