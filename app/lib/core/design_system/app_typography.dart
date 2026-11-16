import 'package:material_ui/material_ui.dart';

abstract final class AppTypography {
  static const trackingTightest = -1.0;
  static const trackingTighter = -0.7;
  static const trackingTight = -0.4;
  static const trackingSlight = -0.2;
  static const trackingSubtle = -0.1;
  static const trackingNormal = 0.0;
  static const trackingRelaxed = 0.1;
  static const trackingWide = 0.2;
  static const trackingWider = 0.3;
  static const trackingWidest = 0.4;

  static TextTheme textTheme(Color primary, Color secondary) => TextTheme(
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w600,
      height: 1.08,
      letterSpacing: trackingTightest,
      color: primary,
    ),
    displayMedium: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w600,
      height: 1.1,
      letterSpacing: trackingTighter,
      color: primary,
    ),
    headlineLarge: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w600,
      height: 1.15,
      letterSpacing: trackingTight,
      color: primary,
    ),
    headlineMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.18,
      letterSpacing: trackingSlight,
      color: primary,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: primary,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: trackingSubtle,
      color: primary,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: primary,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.35,
      letterSpacing: trackingRelaxed,
      color: primary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.55,
      color: primary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: primary,
    ),
    bodySmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.45,
      letterSpacing: trackingRelaxed,
      color: secondary,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.2,
      letterSpacing: trackingWide,
      color: primary,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.2,
      letterSpacing: trackingWider,
      color: secondary,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.25,
      letterSpacing: trackingWidest,
      color: secondary,
    ),
  );
}
