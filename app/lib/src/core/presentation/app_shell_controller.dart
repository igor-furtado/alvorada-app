import 'package:flutter/widgets.dart';

@immutable
class AppShellBreadcrumb {
  const AppShellBreadcrumb({required this.label, this.route});

  final String label;
  final String? route;
}

class AppShellController extends ValueNotifier<List<AppShellBreadcrumb>?> {
  AppShellController() : super(null);

  Object? _owner;

  void setBreadcrumbs(Object owner, List<AppShellBreadcrumb> breadcrumbs) {
    _owner = owner;
    value = List.unmodifiable(breadcrumbs);
  }

  void clearBreadcrumbs(Object owner) {
    if (!identical(_owner, owner)) return;
    _owner = null;
    value = null;
  }

  void resetBreadcrumbs() {
    _owner = null;
    value = null;
  }
}

class AppShellScope extends InheritedNotifier<AppShellController> {
  const AppShellScope({required AppShellController controller, required super.child, super.key})
    : super(notifier: controller);

  static AppShellController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppShellScope>()?.notifier;
}
