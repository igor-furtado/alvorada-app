import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

import 'primitives/app_dimension_primitives.dart';

@immutable
class AppIconTokens {
  const AppIconTokens({
    this.sm = AppDimensionPrimitives.size16,
    this.md = AppDimensionPrimitives.size20,
    this.lg = AppDimensionPrimitives.size24,
    this.xl = AppDimensionPrimitives.size28,
    this.hero = AppDimensionPrimitives.size40,
  });

  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double hero;

  AppIconTokens lerp(AppIconTokens other, double t) => AppIconTokens(
    sm: lerpDouble(sm, other.sm, t)!,
    md: lerpDouble(md, other.md, t)!,
    lg: lerpDouble(lg, other.lg, t)!,
    xl: lerpDouble(xl, other.xl, t)!,
    hero: lerpDouble(hero, other.hero, t)!,
  );
}
