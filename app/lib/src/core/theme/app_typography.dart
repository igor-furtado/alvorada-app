import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static const displayFamily = 'Geist';
  static const bodyFamily = 'Geist';
  static const labelFamily = 'Geist';

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

  static const leadingCompact = 1.2;

  static TextTheme textTheme(Color primary, Color secondary) => TextTheme(
    displayLarge: GoogleFonts.getFont(
      displayFamily,
      fontSize: 48,
      fontWeight: FontWeight.w600,
      height: 1.08,
      letterSpacing: trackingTightest,
      color: primary,
    ),
    displayMedium: GoogleFonts.getFont(
      displayFamily,
      fontSize: 36,
      fontWeight: FontWeight.w600,
      height: 1.1,
      letterSpacing: trackingTighter,
      color: primary,
    ),
    headlineLarge: GoogleFonts.getFont(
      displayFamily,
      fontSize: 30,
      fontWeight: FontWeight.w600,
      height: 1.15,
      letterSpacing: trackingTight,
      color: primary,
    ),
    headlineMedium: GoogleFonts.getFont(
      displayFamily,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.18,
      letterSpacing: trackingSlight,
      color: primary,
    ),
    headlineSmall: GoogleFonts.getFont(
      displayFamily,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: primary,
    ),
    titleLarge: GoogleFonts.getFont(
      labelFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: trackingSubtle,
      color: primary,
    ),
    titleMedium: GoogleFonts.getFont(
      labelFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: primary,
    ),
    titleSmall: GoogleFonts.getFont(
      labelFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.35,
      letterSpacing: trackingRelaxed,
      color: primary,
    ),
    bodyLarge: GoogleFonts.getFont(
      bodyFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.55,
      color: primary,
    ),
    bodyMedium: GoogleFonts.getFont(
      bodyFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: primary,
    ),
    bodySmall: GoogleFonts.getFont(
      bodyFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.45,
      letterSpacing: trackingRelaxed,
      color: secondary,
    ),
    labelLarge: GoogleFonts.getFont(
      labelFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.2,
      letterSpacing: trackingWide,
      color: primary,
    ),
    labelMedium: GoogleFonts.getFont(
      labelFamily,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.2,
      letterSpacing: trackingWider,
      color: secondary,
    ),
    labelSmall: GoogleFonts.getFont(
      labelFamily,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.25,
      letterSpacing: trackingWidest,
      color: secondary,
    ),
  );
}
