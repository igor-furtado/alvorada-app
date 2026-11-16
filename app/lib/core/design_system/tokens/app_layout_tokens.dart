import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

@immutable
class AppLayoutTokens {
  const AppLayoutTokens({
    this.compact = 600,
    this.medium = 840,
    this.expanded = 1200,
    this.contentMaxWidth = 1120,
    this.dialogMaxWidth = 384,
    this.drawerWidth = 460,
    this.iconRailWidth = 216,
    this.inputHeight = 48,
    this.inputHPadding = 12,
    this.toolbar = 620,
    this.contentSplit = 860,
  });

  final double compact;
  final double medium;
  final double expanded;
  final double contentMaxWidth;
  final double dialogMaxWidth;
  final double drawerWidth;
  final double iconRailWidth;
  final double inputHeight;
  final double inputHPadding;
  final double toolbar;
  final double contentSplit;

  AppLayoutTokens lerp(AppLayoutTokens other, double t) => AppLayoutTokens(
    compact: lerpDouble(compact, other.compact, t)!,
    medium: lerpDouble(medium, other.medium, t)!,
    expanded: lerpDouble(expanded, other.expanded, t)!,
    contentMaxWidth: lerpDouble(contentMaxWidth, other.contentMaxWidth, t)!,
    dialogMaxWidth: lerpDouble(dialogMaxWidth, other.dialogMaxWidth, t)!,
    drawerWidth: lerpDouble(drawerWidth, other.drawerWidth, t)!,
    iconRailWidth: lerpDouble(iconRailWidth, other.iconRailWidth, t)!,
    inputHeight: lerpDouble(inputHeight, other.inputHeight, t)!,
    inputHPadding: lerpDouble(inputHPadding, other.inputHPadding, t)!,
    toolbar: lerpDouble(toolbar, other.toolbar, t)!,
    contentSplit: lerpDouble(contentSplit, other.contentSplit, t)!,
  );
}
