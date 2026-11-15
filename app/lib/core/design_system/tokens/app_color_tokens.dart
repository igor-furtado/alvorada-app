import 'package:flutter/material.dart';

import 'primitives/app_color_primitives.dart';

@immutable
class AppColorTokens {
  const AppColorTokens({
    required this.canvas,
    required this.surface,
    required this.card,
    required this.popover,
    required this.surfaceSubtle,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.border,
    required this.controlOutline,
    required this.focusRing,
    required this.primary,
    required this.actionForeground,
    required this.onPrimary,
    required this.primaryContainer,
    required this.success,
    required this.error,
    required this.errorForeground,
    required this.errorContainer,
    required this.info,
    required this.warning,
    required this.warningContainer,
    required this.warningBorder,
    required this.transparent,
    required this.scrim,
  });

  const AppColorTokens.light()
    : this(
        canvas: AppColorPrimitives.zinc50,
        surface: AppColorPrimitives.white,
        card: AppColorPrimitives.white,
        popover: AppColorPrimitives.white,
        surfaceSubtle: AppColorPrimitives.zinc100,
        onSurface: AppColorPrimitives.zinc950,
        onSurfaceMuted: AppColorPrimitives.zinc500,
        border: AppColorPrimitives.zinc200,
        controlOutline: AppColorPrimitives.zinc300,
        focusRing: AppColorPrimitives.zinc950,
        primary: AppColorPrimitives.zinc900,
        actionForeground: AppColorPrimitives.zinc900,
        onPrimary: AppColorPrimitives.zinc50,
        primaryContainer: AppColorPrimitives.zinc100,
        success: AppColorPrimitives.green700,
        error: AppColorPrimitives.redDestructiveLight,
        errorForeground: AppColorPrimitives.red700,
        errorContainer: AppColorPrimitives.redDestructiveContainerLight,
        info: AppColorPrimitives.blue700,
        warning: AppColorPrimitives.amber900,
        warningContainer: AppColorPrimitives.amber50,
        warningBorder: AppColorPrimitives.amber200,
        transparent: AppColorPrimitives.transparent,
        scrim: AppColorPrimitives.black,
      );

  const AppColorTokens.dark()
    : this(
        canvas: AppColorPrimitives.zinc950,
        surface: AppColorPrimitives.zinc950,
        card: AppColorPrimitives.zinc900,
        popover: AppColorPrimitives.zinc900,
        surfaceSubtle: AppColorPrimitives.zinc800,
        onSurface: AppColorPrimitives.zinc50,
        onSurfaceMuted: AppColorPrimitives.zinc400,
        border: AppColorPrimitives.zinc800,
        controlOutline: AppColorPrimitives.zinc700,
        focusRing: AppColorPrimitives.blue300,
        primary: AppColorPrimitives.zinc50,
        actionForeground: AppColorPrimitives.zinc50,
        onPrimary: AppColorPrimitives.zinc900,
        primaryContainer: AppColorPrimitives.zinc800,
        success: AppColorPrimitives.green300,
        error: AppColorPrimitives.redDestructiveDark,
        errorForeground: AppColorPrimitives.red300,
        errorContainer: AppColorPrimitives.redDestructiveContainerDark,
        info: AppColorPrimitives.blue300,
        warning: AppColorPrimitives.amber50,
        warningContainer: AppColorPrimitives.amber950,
        warningBorder: AppColorPrimitives.amber900,
        transparent: AppColorPrimitives.transparent,
        scrim: AppColorPrimitives.black,
      );

  final Color canvas;
  final Color surface;
  final Color card;
  final Color popover;
  final Color surfaceSubtle;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color border;
  final Color controlOutline;
  final Color focusRing;
  final Color primary;
  final Color actionForeground;
  final Color onPrimary;
  final Color primaryContainer;
  final Color success;
  final Color error;
  final Color errorForeground;
  final Color errorContainer;
  final Color info;
  final Color warning;
  final Color warningContainer;
  final Color warningBorder;
  final Color transparent;
  final Color scrim;

  AppColorTokens lerp(AppColorTokens other, double t) => AppColorTokens(
    canvas: Color.lerp(canvas, other.canvas, t)!,
    surface: Color.lerp(surface, other.surface, t)!,
    card: Color.lerp(card, other.card, t)!,
    popover: Color.lerp(popover, other.popover, t)!,
    surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
    onSurface: Color.lerp(onSurface, other.onSurface, t)!,
    onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
    border: Color.lerp(border, other.border, t)!,
    controlOutline: Color.lerp(controlOutline, other.controlOutline, t)!,
    focusRing: Color.lerp(focusRing, other.focusRing, t)!,
    primary: Color.lerp(primary, other.primary, t)!,
    actionForeground: Color.lerp(actionForeground, other.actionForeground, t)!,
    onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
    primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
    success: Color.lerp(success, other.success, t)!,
    error: Color.lerp(error, other.error, t)!,
    errorForeground: Color.lerp(errorForeground, other.errorForeground, t)!,
    errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
    info: Color.lerp(info, other.info, t)!,
    warning: Color.lerp(warning, other.warning, t)!,
    warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
    warningBorder: Color.lerp(warningBorder, other.warningBorder, t)!,
    transparent: Color.lerp(transparent, other.transparent, t)!,
    scrim: Color.lerp(scrim, other.scrim, t)!,
  );
}
