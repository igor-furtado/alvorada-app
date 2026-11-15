import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

@immutable
class AppSpacingTokens {
  const AppSpacingTokens({
    this.none = 0,
    this.hairline = 1,
    this.xxxs = 2,
    this.xxs = 4,
    this.xs = 6,
    this.sm = 8,
    this.md = 12,
    this.lg = 16,
    this.xl = 20,
    this.xxl = 24,
    this.xxxl = 32,
    this.huge = 48,
    this.giant = 64,
    this.jumbo = 80,
    this.page = 32,
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
