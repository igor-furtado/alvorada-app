import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens/primitives/app_typography_primitives.dart';

abstract final class AppTypography {
  static TextTheme textTheme(Color primary, Color secondary) => TextTheme(
    displayLarge: GoogleFonts.getFont(
      AppTypographyPrimitives.displayFamily,
      fontSize: AppTypographyPrimitives.size48,
      fontWeight: AppTypographyPrimitives.semibold,
      height: AppTypographyPrimitives.leadingDisplayLarge,
      letterSpacing: AppTypographyPrimitives.trackingTightest,
      color: primary,
    ),
    displayMedium: GoogleFonts.getFont(
      AppTypographyPrimitives.displayFamily,
      fontSize: AppTypographyPrimitives.size40,
      fontWeight: AppTypographyPrimitives.semibold,
      height: AppTypographyPrimitives.leadingDisplayMedium,
      letterSpacing: AppTypographyPrimitives.trackingTighter,
      color: primary,
    ),
    headlineLarge: GoogleFonts.getFont(
      AppTypographyPrimitives.displayFamily,
      fontSize: AppTypographyPrimitives.size32,
      fontWeight: AppTypographyPrimitives.semibold,
      height: AppTypographyPrimitives.leadingHeadlineLarge,
      letterSpacing: AppTypographyPrimitives.trackingTight,
      color: primary,
    ),
    headlineMedium: GoogleFonts.getFont(
      AppTypographyPrimitives.displayFamily,
      fontSize: AppTypographyPrimitives.size26,
      fontWeight: AppTypographyPrimitives.semibold,
      height: AppTypographyPrimitives.leadingHeadlineMedium,
      letterSpacing: AppTypographyPrimitives.trackingSlight,
      color: primary,
    ),
    headlineSmall: GoogleFonts.getFont(
      AppTypographyPrimitives.displayFamily,
      fontSize: AppTypographyPrimitives.size22,
      fontWeight: AppTypographyPrimitives.semibold,
      height: AppTypographyPrimitives.leadingCompact,
      color: primary,
    ),
    titleLarge: GoogleFonts.getFont(
      AppTypographyPrimitives.labelFamily,
      fontSize: AppTypographyPrimitives.size20,
      fontWeight: AppTypographyPrimitives.semibold,
      height: AppTypographyPrimitives.leadingTitleLarge,
      letterSpacing: AppTypographyPrimitives.trackingSubtle,
      color: primary,
    ),
    titleMedium: GoogleFonts.getFont(
      AppTypographyPrimitives.labelFamily,
      fontSize: AppTypographyPrimitives.size16,
      fontWeight: AppTypographyPrimitives.semibold,
      height: AppTypographyPrimitives.leadingTitleMedium,
      color: primary,
    ),
    titleSmall: GoogleFonts.getFont(
      AppTypographyPrimitives.labelFamily,
      fontSize: AppTypographyPrimitives.size14,
      fontWeight: AppTypographyPrimitives.semibold,
      height: AppTypographyPrimitives.leadingTitleSmall,
      letterSpacing: AppTypographyPrimitives.trackingRelaxed,
      color: primary,
    ),
    bodyLarge: GoogleFonts.getFont(
      AppTypographyPrimitives.bodyFamily,
      fontSize: AppTypographyPrimitives.size18,
      fontWeight: AppTypographyPrimitives.regular,
      height: AppTypographyPrimitives.leadingBodyLarge,
      color: primary,
    ),
    bodyMedium: GoogleFonts.getFont(
      AppTypographyPrimitives.bodyFamily,
      fontSize: AppTypographyPrimitives.size16,
      fontWeight: AppTypographyPrimitives.regular,
      height: AppTypographyPrimitives.leadingBodyMedium,
      color: primary,
    ),
    bodySmall: GoogleFonts.getFont(
      AppTypographyPrimitives.bodyFamily,
      fontSize: AppTypographyPrimitives.size14,
      fontWeight: AppTypographyPrimitives.regular,
      height: AppTypographyPrimitives.leadingBodySmall,
      letterSpacing: AppTypographyPrimitives.trackingRelaxed,
      color: secondary,
    ),
    labelLarge: GoogleFonts.getFont(
      AppTypographyPrimitives.labelFamily,
      fontSize: AppTypographyPrimitives.size14,
      fontWeight: AppTypographyPrimitives.semibold,
      height: AppTypographyPrimitives.leadingCompact,
      letterSpacing: AppTypographyPrimitives.trackingWide,
      color: primary,
    ),
    labelMedium: GoogleFonts.getFont(
      AppTypographyPrimitives.labelFamily,
      fontSize: AppTypographyPrimitives.size12,
      fontWeight: AppTypographyPrimitives.semibold,
      height: AppTypographyPrimitives.leadingCompact,
      letterSpacing: AppTypographyPrimitives.trackingWider,
      color: secondary,
    ),
    labelSmall: GoogleFonts.getFont(
      AppTypographyPrimitives.labelFamily,
      fontSize: AppTypographyPrimitives.size11,
      fontWeight: AppTypographyPrimitives.medium,
      height: AppTypographyPrimitives.leadingTitleLarge,
      letterSpacing: AppTypographyPrimitives.trackingWidest,
      color: secondary,
    ),
  );
}
