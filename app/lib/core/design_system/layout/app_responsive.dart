import 'package:flutter/material.dart';

import '../app_tokens.dart';

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
  AppWindowClass get windowClass {
    final screenSize = MediaQuery.sizeOf(this);
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

typedef ResponsiveWidgetBuilder = Widget Function(BuildContext context, AppWindowClass windowClass);

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({required this.builder, super.key});

  final ResponsiveWidgetBuilder builder;

  @override
  Widget build(BuildContext context) => builder(context, context.windowClass);
}
