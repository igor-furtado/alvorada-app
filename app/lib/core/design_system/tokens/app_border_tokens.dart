import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';

@immutable
class AppBorderTokens {
  const AppBorderTokens({
    this.widthHairline = 1,
    this.widthEmphasis = 1.5,
    this.widthStrong = 2,
    this.radiusXs = 4,
    this.radiusSm = 6,
    this.radiusMd = 6,
    this.radiusLg = 8,
    this.radiusXl = 12,
    this.radius2xl = 16,
    this.radiusFull = 999,
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
  final double radiusFull;

  BorderRadius get xs => BorderRadius.circular(radiusXs);
  BorderRadius get sm => BorderRadius.circular(radiusSm);
  BorderRadius get md => BorderRadius.circular(radiusMd);
  BorderRadius get lg => BorderRadius.circular(radiusLg);
  BorderRadius get xl => BorderRadius.circular(radiusXl);
  BorderRadius get xxl => BorderRadius.circular(radius2xl);
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
    radiusFull: lerpDouble(radiusFull, other.radiusFull, t)!,
  );
}
