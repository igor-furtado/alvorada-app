import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum AppWindowClass {
  compact,
  medium,
  expanded,
  large;

  bool get isCompact => this == AppWindowClass.compact;
  bool get isMedium => this == AppWindowClass.medium;
  bool get isExpanded => this == AppWindowClass.expanded || this == AppWindowClass.large;
}

extension AppResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  AppWindowClass get windowClass {
    final width = screenSize.width;
    final layout = tokens.layout;
    if (width < layout.compact) return AppWindowClass.compact;
    if (width < layout.medium) return AppWindowClass.medium;
    if (width < layout.expanded) return AppWindowClass.expanded;
    return AppWindowClass.large;
  }

  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);

  Duration motionDuration(Duration duration) => reduceMotion ? Duration.zero : duration;
}

class ResponsiveValue<T> {
  const ResponsiveValue({required this.compact, this.medium, this.expanded, this.large});

  final T compact;
  final T? medium;
  final T? expanded;
  final T? large;

  T resolve(AppWindowClass windowClass) => switch (windowClass) {
    AppWindowClass.compact => compact,
    AppWindowClass.medium => medium ?? compact,
    AppWindowClass.expanded => expanded ?? medium ?? compact,
    AppWindowClass.large => large ?? expanded ?? medium ?? compact,
  };
}

typedef ResponsiveWidgetBuilder = Widget Function(BuildContext context, AppWindowClass windowClass);

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({required this.builder, super.key});

  final ResponsiveWidgetBuilder builder;

  @override
  Widget build(BuildContext context) => builder(context, context.windowClass);
}
