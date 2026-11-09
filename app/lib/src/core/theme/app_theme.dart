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

    final radius = tokens.borders.sm;
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
      hoverColor: colors.surfaceSubtle,
      highlightColor: colors.primaryContainer.withValues(
        alpha: tokens.opacity.tintStrong,
      ),
      splashFactory: NoSplash.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.canvas,
        foregroundColor: colors.onSurface,
        elevation: 0,
        surfaceTintColor: colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceElevated,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: tokens.elevations.low.first.color,
        surfaceTintColor: colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
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
          padding: EdgeInsets.symmetric(horizontal: tokens.spacing.lg),
          elevation: 0,
          disabledBackgroundColor: colors.surfaceSubtle,
          disabledForegroundColor: colors.onSurfaceMuted,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size.square(tokens.layout.controlHeight),
          foregroundColor: colors.onSurface,
          side: BorderSide(color: colors.border),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: radius),
          padding: EdgeInsets.symmetric(horizontal: tokens.spacing.lg),
          backgroundColor: colors.surfaceElevated,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.actionForeground,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: radius),
          minimumSize: Size.square(tokens.layout.controlHeight),
          padding: EdgeInsets.symmetric(horizontal: tokens.spacing.md),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: Size.square(tokens.layout.controlHeight),
          foregroundColor: colors.onSurface,
          backgroundColor: colors.transparent,
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
        backgroundColor: colors.surfaceElevated,
        selectedColor: colors.primaryContainer,
        side: BorderSide(color: colors.border),
        shape: RoundedRectangleBorder(borderRadius: tokens.borders.sm),
        labelStyle: textTheme.labelMedium,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceElevated,
        surfaceTintColor: colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: tokens.borders.md,
          side: BorderSide(color: colors.border),
        ),
        titleTextStyle: textTheme.headlineSmall,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.transparent,
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? colors.actionForeground : colors.onSurfaceMuted,
            size: tokens.icons.md,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected) ? colors.onSurface : colors.onSurfaceMuted,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.surface,
        selectedIconTheme: IconThemeData(color: colors.onSurface),
        unselectedIconTheme: IconThemeData(color: colors.onSurfaceMuted),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: colors.onSurface,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium,
        indicatorColor: colors.surfaceSubtle,
        indicatorShape: RoundedRectangleBorder(borderRadius: radius),
        elevation: 0,
      ),
      listTileTheme: ListTileThemeData(
        dense: true,
        minTileHeight: tokens.layout.controlHeight,
        iconColor: colors.onSurfaceMuted,
        textColor: colors.onSurfaceMuted,
        selectedColor: colors.onSurface,
        selectedTileColor: colors.surfaceSubtle,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: tokens.borders.xs),
        side: BorderSide(color: colors.controlOutline),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? colors.primary : colors.transparent,
        ),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? colors.primary : colors.surfaceSubtle,
        ),
        thumbColor: WidgetStatePropertyAll(colors.surfaceElevated),
        trackOutlineColor: WidgetStatePropertyAll(colors.border),
      ),
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: tokens.borders.widthHairline,
        space: tokens.spacing.hairline,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.onSurface,
          borderRadius: tokens.borders.sm,
        ),
        textStyle: textTheme.labelMedium?.copyWith(color: colors.canvas),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.surfaceSubtle,
        borderRadius: tokens.borders.xs,
      ),
    );
  }
}
