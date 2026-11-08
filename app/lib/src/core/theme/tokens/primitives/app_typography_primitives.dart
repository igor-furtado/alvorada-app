import 'package:flutter/material.dart';

/// Escala tipográfica bruta. A aplicação ocorre em [TextTheme].
abstract final class AppTypographyPrimitives {
  static const displayFamily = 'Fraunces';
  static const bodyFamily = 'Newsreader';
  static const labelFamily = 'Inter';

  static const size11 = 11.0;
  static const size12 = 12.0;
  static const size14 = 14.0;
  static const size16 = 16.0;
  static const size18 = 18.0;
  static const size20 = 20.0;
  static const size22 = 22.0;
  static const size26 = 26.0;
  static const size32 = 32.0;
  static const size40 = 40.0;
  static const size48 = 48.0;

  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semibold = FontWeight.w600;

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

  static const leadingDisplayLarge = 1.08;
  static const leadingDisplayMedium = 1.10;
  static const leadingHeadlineLarge = 1.15;
  static const leadingHeadlineMedium = 1.18;
  static const leadingCompact = 1.20;
  static const leadingTitleLarge = 1.25;
  static const leadingTitleMedium = 1.30;
  static const leadingTitleSmall = 1.35;
  static const leadingBodySmall = 1.45;
  static const leadingBodyMedium = 1.50;
  static const leadingBodyLarge = 1.55;
}
