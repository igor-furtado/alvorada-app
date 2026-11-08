import 'package:flutter/material.dart';

import 'app_typography.dart';
import 'tokens/tokens.dart';

export 'app_icons.dart';
export 'app_typography.dart';
export 'tokens/tokens.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final tokens = dark ? AppTokens.dark() : AppTokens.light();
    final colors = tokens.colors;
    final textTheme = AppTypography.textTheme(
      colors.onSurface,
      colors.onSurfaceMuted,
    );

    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.primaryContainer,
      onPrimaryContainer: colors.onPrimaryContainer,
      secondary: colors.success,
      onSecondary: colors.onSuccess,
      secondaryContainer: colors.successContainer,
      onSecondaryContainer: colors.onSurface,
      tertiary: colors.info,
      onTertiary: colors.onInfo,
      error: colors.error,
      onError: colors.onError,
      errorContainer: colors.errorContainer,
      onErrorContainer: colors.onSurface,
      surface: colors.surface,
      onSurface: colors.onSurface,
      surfaceContainerHighest: colors.surfaceSubtle,
      outline: colors.controlOutline,
      outlineVariant: colors.border.withValues(alpha: tokens.opacity.border),
      shadow: colors.shadow,
      scrim: colors.scrim,
      inverseSurface: colors.onSurface,
      onInverseSurface: colors.canvas,
      inversePrimary: colors.primary,
    );

    final radius = tokens.borders.md;
    final inputBorder = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: colors.controlOutline),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: [tokens],
      scaffoldBackgroundColor: colors.canvas,
      textTheme: textTheme,
      dividerColor: colors.border,
      focusColor: colors.focusRing.withValues(alpha: tokens.opacity.tintStrong),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.canvas,
        foregroundColor: colors.onSurface,
        elevation: 0,
        surfaceTintColor: colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: tokens.elevations.low.first.color,
        surfaceTintColor: colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: tokens.borders.lg,
          side: BorderSide(color: colors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size.square(tokens.layout.controlHeight),
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: radius),
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacing.xl,
            vertical: tokens.spacing.md,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size.square(tokens.layout.controlHeight),
          foregroundColor: colors.onSurface,
          side: BorderSide(color: colors.border),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: radius),
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacing.xl,
            vertical: tokens.spacing.md,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.actionForeground,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceElevated,
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceMuted,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceMuted),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: colors.focusRing,
            width: tokens.borders.widthStrong,
          ),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: colors.error,
            width: tokens.borders.widthEmphasis,
          ),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: colors.error,
            width: tokens.borders.widthStrong,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.md,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surface,
        selectedColor: colors.primaryContainer,
        side: BorderSide(color: colors.border),
        shape: RoundedRectangleBorder(borderRadius: tokens.borders.sm),
        labelStyle: textTheme.labelMedium,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceElevated,
        surfaceTintColor: colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: tokens.borders.lg),
        titleTextStyle: textTheme.headlineSmall,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.onSurfaceMuted,
        selectedLabelStyle: textTheme.labelSmall,
        unselectedLabelStyle: textTheme.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.surface,
        selectedIconTheme: IconThemeData(color: colors.primary),
        unselectedIconTheme: IconThemeData(color: colors.onSurfaceMuted),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: colors.onSurface,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium,
        indicatorColor: colors.primaryContainer,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.surfaceSubtle,
        borderRadius: tokens.borders.xs,
      ),
    );
  }
}
