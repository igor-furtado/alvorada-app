import 'package:flutter/material.dart';

import '../app_typography.dart';

@immutable
class AppTypographyTokens {
  const AppTypographyTokens._(this.textTheme);

  factory AppTypographyTokens.fromColors(Color primary, Color secondary) =>
      AppTypographyTokens._(AppTypography.textTheme(primary, secondary));

  final TextTheme textTheme;

  TextStyle get displayLarge => textTheme.displayLarge!;
  TextStyle get displayMedium => textTheme.displayMedium!;
  TextStyle get headlineLarge => textTheme.headlineLarge!;
  TextStyle get headlineMedium => textTheme.headlineMedium!;
  TextStyle get headlineSmall => textTheme.headlineSmall!;
  TextStyle get titleLarge => textTheme.titleLarge!;
  TextStyle get titleMedium => textTheme.titleMedium!;
  TextStyle get titleSmall => textTheme.titleSmall!;
  TextStyle get bodyLarge => textTheme.bodyLarge!;
  TextStyle get bodyMedium => textTheme.bodyMedium!;
  TextStyle get bodySmall => textTheme.bodySmall!;
  TextStyle get labelLarge => textTheme.labelLarge!;
  TextStyle get labelMedium => textTheme.labelMedium!;
  TextStyle get labelSmall => textTheme.labelSmall!;
  TextStyle get button => textTheme.labelLarge!.copyWith(
    fontWeight: FontWeight.w500,
    height: AppTypography.leadingCompact,
    letterSpacing: AppTypography.trackingNormal,
  );

  AppTypographyTokens lerp(AppTypographyTokens other, double t) =>
      AppTypographyTokens._(TextTheme.lerp(textTheme, other.textTheme, t));
}
