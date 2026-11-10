import 'package:flutter/material.dart';

class AppThemeModeController extends ValueNotifier<ThemeMode> {
  AppThemeModeController() : super(ThemeMode.system);

  void toggle(Brightness currentBrightness) {
    value = currentBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

class AppThemeModeScope extends InheritedNotifier<AppThemeModeController> {
  const AppThemeModeScope({
    required AppThemeModeController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppThemeModeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppThemeModeScope>();
    assert(scope != null, 'AppThemeModeScope não encontrado na árvore.');
    return scope!.notifier!;
  }
}
