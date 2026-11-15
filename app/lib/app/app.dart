import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/design_system/design_system.dart';
import '../l10n/app_localization_delegates.dart';
import '../l10n/generated/app_localizations.dart';
import 'app_brand.dart';
import 'app_dependencies.dart';
import 'app_router.dart';
import 'app_theme_controller.dart';

class EstudosApp extends StatefulWidget {
  const EstudosApp({this.dependencies, this.locale, super.key});

  final AppDependencies? dependencies;
  final Locale? locale;

  @override
  State<EstudosApp> createState() => _EstudosAppState();
}

class _EstudosAppState extends State<EstudosApp> {
  late final bool _ownsDependencies;
  late final AppDependencies _dependencies;
  late final AppThemeController _themeController;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _ownsDependencies = widget.dependencies == null;
    _dependencies = widget.dependencies ?? AppDependencies.production();
    _themeController = AppThemeController();
    _router = createAppRouter();
  }

  @override
  void dispose() {
    _router.dispose();
    _themeController.dispose();
    if (_ownsDependencies) _dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppThemeScope(
    controller: _themeController,
    child: AppDependenciesProvider(
      dependencies: _dependencies,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeController,
        builder: (context, themeMode, child) => MaterialApp.router(
          title: AppBrand.applicationTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          locale: widget.locale,
          localizationsDelegates: appLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          restorationScopeId: 'application',
          routerConfig: _router,
        ),
      ),
    ),
  );
}
