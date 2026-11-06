import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTypography {
  static TextTheme textTheme(Color primary, Color secondary) => TextTheme(
    displayLarge: GoogleFonts.fraunces(
      fontSize: 48,
      fontWeight: FontWeight.w600,
      height: 1.08,
      letterSpacing: -1,
      color: primary,
    ),
    displayMedium: GoogleFonts.fraunces(
      fontSize: 40,
      fontWeight: FontWeight.w600,
      height: 1.10,
      letterSpacing: -.7,
      color: primary,
    ),
    headlineLarge: GoogleFonts.fraunces(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.15,
      letterSpacing: -.4,
      color: primary,
    ),
    headlineMedium: GoogleFonts.fraunces(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      height: 1.18,
      letterSpacing: -.2,
      color: primary,
    ),
    headlineSmall: GoogleFonts.fraunces(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.20,
      color: primary,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.25,
      letterSpacing: -.1,
      color: primary,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.30,
      color: primary,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.35,
      letterSpacing: .1,
      color: primary,
    ),
    bodyLarge: GoogleFonts.newsreader(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 1.55,
      color: primary,
    ),
    bodyMedium: GoogleFonts.newsreader(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.50,
      color: primary,
    ),
    bodySmall: GoogleFonts.newsreader(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.45,
      letterSpacing: .1,
      color: secondary,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.20,
      letterSpacing: .2,
      color: primary,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.20,
      letterSpacing: .3,
      color: secondary,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.25,
      letterSpacing: .4,
      color: secondary,
    ),
  );
}
