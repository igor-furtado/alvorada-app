import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

import 'primitives/app_dimension_primitives.dart';

@immutable
class AppSpacingTokens {
  const AppSpacingTokens({
    this.none = AppDimensionPrimitives.zero,
    this.hairline = AppDimensionPrimitives.size1,
    this.xxxs = AppDimensionPrimitives.size2,
    this.xxs = AppDimensionPrimitives.size4,
    this.xs = AppDimensionPrimitives.size6,
    this.sm = AppDimensionPrimitives.size8,
    this.md = AppDimensionPrimitives.size12,
    this.lg = AppDimensionPrimitives.size16,
    this.xl = AppDimensionPrimitives.size20,
    this.xxl = AppDimensionPrimitives.size24,
    this.xxxl = AppDimensionPrimitives.size32,
    this.huge = AppDimensionPrimitives.size48,
    this.giant = AppDimensionPrimitives.size64,
    this.jumbo = 80,
    this.page = AppDimensionPrimitives.size32,
  });

  final double none;
  final double hairline;
  final double xxxs;
  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;
  final double huge;
  final double giant;
  final double jumbo;
  final double page;

  AppSpacingTokens lerp(AppSpacingTokens other, double t) => AppSpacingTokens(
    none: lerpDouble(none, other.none, t)!,
    hairline: lerpDouble(hairline, other.hairline, t)!,
    xxxs: lerpDouble(xxxs, other.xxxs, t)!,
    xxs: lerpDouble(xxs, other.xxs, t)!,
    xs: lerpDouble(xs, other.xs, t)!,
    sm: lerpDouble(sm, other.sm, t)!,
    md: lerpDouble(md, other.md, t)!,
    lg: lerpDouble(lg, other.lg, t)!,
    xl: lerpDouble(xl, other.xl, t)!,
    xxl: lerpDouble(xxl, other.xxl, t)!,
    xxxl: lerpDouble(xxxl, other.xxxl, t)!,
    huge: lerpDouble(huge, other.huge, t)!,
    giant: lerpDouble(giant, other.giant, t)!,
    jumbo: lerpDouble(jumbo, other.jumbo, t)!,
    page: lerpDouble(page, other.page, t)!,
  );
}
