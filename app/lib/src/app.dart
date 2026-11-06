import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/studies/presentation/pages/dashboard_page.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
  ],
);

class EstudosApp extends StatelessWidget {
  const EstudosApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Foco — Meus estudos',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    routerConfig: _router,
  );
}
