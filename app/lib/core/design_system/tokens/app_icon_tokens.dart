import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

@immutable
class AppIconTokens {
  const AppIconTokens({
    this.sm = 16,
    this.md = 20,
    this.lg = 24,
  });

  final double sm;
  final double md;
  final double lg;

  AppIconTokens lerp(AppIconTokens other, double t) => AppIconTokens(
    sm: lerpDouble(sm, other.sm, t)!,
    md: lerpDouble(md, other.md, t)!,
    lg: lerpDouble(lg, other.lg, t)!,
  );
}
