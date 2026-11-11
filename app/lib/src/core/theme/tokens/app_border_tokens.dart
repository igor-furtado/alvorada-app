import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'primitives/app_dimension_primitives.dart';

@immutable
class AppBorderTokens {
  const AppBorderTokens({
    this.widthHairline = AppDimensionPrimitives.size1,
    this.widthEmphasis = 1.5,
    this.widthStrong = AppDimensionPrimitives.size2,
    this.radiusXs = AppDimensionPrimitives.size4,
    this.radiusSm = AppDimensionPrimitives.size6,
    this.radiusMd = AppDimensionPrimitives.size6,
    this.radiusLg = AppDimensionPrimitives.size8,
    this.radiusXl = AppDimensionPrimitives.size12,
    this.radius2xl = AppDimensionPrimitives.size16,
    this.radius3xl = AppDimensionPrimitives.size24,
    this.radiusFull = AppDimensionPrimitives.full,
  });

  final double widthHairline;
  final double widthEmphasis;
  final double widthStrong;
  final double radiusXs;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double radius2xl;
  final double radius3xl;
  final double radiusFull;

  BorderRadius get xs => BorderRadius.circular(radiusXs);
  BorderRadius get sm => BorderRadius.circular(radiusSm);
  BorderRadius get md => BorderRadius.circular(radiusMd);
  BorderRadius get lg => BorderRadius.circular(radiusLg);
  BorderRadius get xl => BorderRadius.circular(radiusXl);
  BorderRadius get xxl => BorderRadius.circular(radius2xl);
  BorderRadius get xxxl => BorderRadius.circular(radius3xl);
  BorderRadius get full => BorderRadius.circular(radiusFull);

  AppBorderTokens lerp(AppBorderTokens other, double t) => AppBorderTokens(
    widthHairline: lerpDouble(widthHairline, other.widthHairline, t)!,
    widthEmphasis: lerpDouble(widthEmphasis, other.widthEmphasis, t)!,
    widthStrong: lerpDouble(widthStrong, other.widthStrong, t)!,
    radiusXs: lerpDouble(radiusXs, other.radiusXs, t)!,
    radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
    radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
    radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
    radiusXl: lerpDouble(radiusXl, other.radiusXl, t)!,
    radius2xl: lerpDouble(radius2xl, other.radius2xl, t)!,
    radius3xl: lerpDouble(radius3xl, other.radius3xl, t)!,
    radiusFull: lerpDouble(radiusFull, other.radiusFull, t)!,
  );
}
