import 'package:flutter/material.dart';

@immutable
class AppShellSearchConfig {
  const AppShellSearchConfig({
    required this.placeholder,
    required this.onChanged,
    this.query = '',
    this.actionIcon,
    this.actionLabel,
    this.onAction,
  });

  final String placeholder;
  final ValueChanged<String> onChanged;
  final String query;
  final IconData? actionIcon;
  final String? actionLabel;
  final VoidCallback? onAction;
}

class AppShellController extends ValueNotifier<AppShellSearchConfig?> {
  AppShellController() : super(null);

  Object? _owner;

  void setSearch(Object owner, AppShellSearchConfig config) {
    _owner = owner;
    value = config;
  }

  void clearSearch(Object owner) {
    if (identical(_owner, owner)) {
      _owner = null;
      value = null;
    }
  }
}

class AppShellScope extends InheritedWidget {
  const AppShellScope({
    required this.controller,
    required super.child,
    super.key,
  });

  final AppShellController controller;

  static AppShellController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppShellScope>();
    assert(scope != null, 'AppShellScope não encontrado na árvore.');
    return scope!.controller;
  }

  @override
  bool updateShouldNotify(AppShellScope oldWidget) => controller != oldWidget.controller;
}
