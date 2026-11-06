import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

export 'app_colors.dart';
export 'app_icons.dart';
export 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final background = dark ? AppColors.madrugada : AppColors.papel;
    final surface = dark
        ? AppColors.madrugadaSuperficie
        : AppColors.papelElevado;
    final elevated = dark ? AppColors.madrugadaElevada : AppColors.papelElevado;
    final ink = dark ? AppColors.papelNoEscuro : AppColors.tinta;
    final muted = dark ? AppColors.papelSuaveNoEscuro : AppColors.tintaSuave;
    final border = dark ? AppColors.linhaNoEscuro : AppColors.linha;
    final primary = dark ? AppColors.solNoEscuro : AppColors.sol;
    final error = dark ? AppColors.canetaNoEscuro : AppColors.canetaVermelha;
    final textTheme = AppTypography.textTheme(ink, muted);

    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: AppColors.tinta,
      primaryContainer: dark ? const Color(0xFF5A2D13) : AppColors.solSuave,
      onPrimaryContainer: ink,
      secondary: dark ? AppColors.salviaNoEscuro : AppColors.salviaTexto,
      onSecondary: dark ? AppColors.madrugada : Colors.white,
      secondaryContainer: dark
          ? AppColors.descansoNoEscuro
          : AppColors.descanso,
      onSecondaryContainer: ink,
      tertiary: dark ? const Color(0xFFB8ACE0) : AppColors.jurisprudenciaTinta,
      onTertiary: dark ? AppColors.madrugada : Colors.white,
      error: error,
      onError: dark ? AppColors.madrugada : Colors.white,
      surface: surface,
      onSurface: ink,
      surfaceContainerHighest: dark
          ? AppColors.madrugadaElevada
          : AppColors.papelSombra,
      outline: border,
      outlineVariant: border.withValues(alpha: .72),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: ink,
      onInverseSurface: background,
      inversePrimary: primary,
    );

    const radius = BorderRadius.all(Radius.circular(8));
    final inputBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: border),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      dividerColor: border,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withValues(alpha: .05),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: primary,
          foregroundColor: AppColors.tinta,
          textStyle: textTheme.labelLarge,
          shape: const RoundedRectangleBorder(borderRadius: radius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: ink,
          side: BorderSide(color: border),
          textStyle: textTheme.labelLarge,
          shape: const RoundedRectangleBorder(borderRadius: radius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: dark ? primary : AppColors.tinta,
          textStyle: textTheme.labelLarge,
          shape: const RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevated,
        labelStyle: textTheme.bodyMedium?.copyWith(color: muted),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: muted.withValues(alpha: .78),
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: dark ? const Color(0xFF5A2D13) : AppColors.solSuave,
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        labelStyle: textTheme.labelMedium,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: elevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: textTheme.headlineSmall,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: muted,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        selectedIconTheme: IconThemeData(color: primary),
        unselectedIconTheme: IconThemeData(color: muted),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(color: ink),
        unselectedLabelTextStyle: textTheme.labelMedium,
        indicatorColor: dark ? const Color(0xFF5A2D13) : AppColors.solSuave,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: dark
            ? AppColors.linhaNoEscuro
            : AppColors.papelSombra,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
