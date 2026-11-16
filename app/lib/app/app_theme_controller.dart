import 'package:material_ui/material_ui.dart';

class AppThemeController extends ValueNotifier<ThemeMode> {
  AppThemeController() : super(ThemeMode.system);

  ThemeMode get mode => value;

  void toggle(Brightness currentBrightness) {
    value = currentBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
  }

  set mode(ThemeMode mode) => value = mode;
}

class AppThemeScope extends InheritedNotifier<AppThemeController> {
  const AppThemeScope({
    required AppThemeController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeScope>();
    assert(scope != null, 'AppThemeScope não encontrado na árvore.');
    return scope!.notifier!;
  }
}
