import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'tokens/app_tokens.dart';

/// Tema shadcn que traduz a identidade mineral do Prumo.app para os
/// componentes fornecidos por `shadcn_ui`.
abstract final class AppShadTheme {
  static final light = _build(Brightness.light);
  static final dark = _build(Brightness.dark);

  static ShadThemeData _build(Brightness brightness) {
    final tokens = brightness == Brightness.dark ? AppTokens.dark() : AppTokens.light();
    final colors = tokens.colors;

    return ShadThemeData(
      brightness: brightness,
      radius: tokens.borders.sm,
      textTheme: ShadTextTheme(
        family: GoogleFonts.inter().fontFamily,
        googleFontBuilder: GoogleFonts.inter,
      ),
      colorScheme: ShadColorScheme(
        background: colors.canvas,
        foreground: colors.onSurface,
        card: colors.surfaceElevated,
        cardForeground: colors.onSurface,
        popover: colors.surfaceElevated,
        popoverForeground: colors.onSurface,
        primary: colors.primary,
        primaryForeground: colors.onPrimary,
        secondary: colors.surfaceSubtle,
        secondaryForeground: colors.onSurface,
        muted: colors.surfaceSubtle,
        mutedForeground: colors.onSurfaceMuted,
        accent: colors.primaryContainer,
        accentForeground: colors.onPrimaryContainer,
        destructive: colors.error,
        destructiveForeground: colors.onError,
        border: colors.border,
        input: colors.controlOutline,
        ring: colors.focusRing,
        selection: colors.primaryContainer,
      ),
    );
  }
}
