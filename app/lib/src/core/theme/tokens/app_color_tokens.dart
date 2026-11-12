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
    required this.onPrimaryContainer,
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.error,
    required this.errorForeground,
    required this.onError,
    required this.errorContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.warning,
    required this.warningContainer,
    required this.warningBorder,
    required this.restContainer,
    required this.memorizeContainer,
    required this.attentionContainer,
    required this.observationContainer,
    required this.transparent,
    required this.shadow,
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
        onPrimaryContainer: AppColorPrimitives.zinc900,
        success: AppColorPrimitives.green700,
        onSuccess: AppColorPrimitives.white,
        successContainer: AppColorPrimitives.green50,
        error: AppColorPrimitives.redDestructiveLight,
        errorForeground: AppColorPrimitives.red700,
        onError: AppColorPrimitives.white,
        errorContainer: AppColorPrimitives.redDestructiveContainerLight,
        info: AppColorPrimitives.blue700,
        onInfo: AppColorPrimitives.white,
        infoContainer: AppColorPrimitives.blue50,
        warning: AppColorPrimitives.amber900,
        warningContainer: AppColorPrimitives.amber50,
        warningBorder: AppColorPrimitives.amber200,
        restContainer: AppColorPrimitives.green50,
        memorizeContainer: AppColorPrimitives.amber50,
        attentionContainer: AppColorPrimitives.red50,
        observationContainer: AppColorPrimitives.blue50,
        transparent: AppColorPrimitives.transparent,
        shadow: AppColorPrimitives.black,
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
        onPrimaryContainer: AppColorPrimitives.zinc50,
        success: AppColorPrimitives.green300,
        onSuccess: AppColorPrimitives.green950,
        successContainer: AppColorPrimitives.green950,
        error: AppColorPrimitives.redDestructiveDark,
        errorForeground: AppColorPrimitives.red300,
        onError: AppColorPrimitives.red950,
        errorContainer: AppColorPrimitives.redDestructiveContainerDark,
        info: AppColorPrimitives.blue300,
        onInfo: AppColorPrimitives.blue950,
        infoContainer: AppColorPrimitives.blue950,
        warning: AppColorPrimitives.amber50,
        warningContainer: AppColorPrimitives.amber950,
        warningBorder: AppColorPrimitives.amber900,
        restContainer: AppColorPrimitives.green950,
        memorizeContainer: AppColorPrimitives.amber950,
        attentionContainer: AppColorPrimitives.red950,
        observationContainer: AppColorPrimitives.blue950,
        transparent: AppColorPrimitives.transparent,
        shadow: AppColorPrimitives.black,
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
  final Color onPrimaryContainer;
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color error;
  final Color errorForeground;
  final Color onError;
  final Color errorContainer;
  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color warning;
  final Color warningContainer;
  final Color warningBorder;
  final Color restContainer;
  final Color memorizeContainer;
  final Color attentionContainer;
  final Color observationContainer;
  final Color transparent;
  final Color shadow;
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
    onPrimaryContainer: Color.lerp(
      onPrimaryContainer,
      other.onPrimaryContainer,
      t,
    )!,
    success: Color.lerp(success, other.success, t)!,
    onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
    successContainer: Color.lerp(successContainer, other.successContainer, t)!,
    error: Color.lerp(error, other.error, t)!,
    errorForeground: Color.lerp(errorForeground, other.errorForeground, t)!,
    onError: Color.lerp(onError, other.onError, t)!,
    errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
    info: Color.lerp(info, other.info, t)!,
    onInfo: Color.lerp(onInfo, other.onInfo, t)!,
    infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
    warning: Color.lerp(warning, other.warning, t)!,
    warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
    warningBorder: Color.lerp(warningBorder, other.warningBorder, t)!,
    restContainer: Color.lerp(restContainer, other.restContainer, t)!,
    memorizeContainer: Color.lerp(
      memorizeContainer,
      other.memorizeContainer,
      t,
    )!,
    attentionContainer: Color.lerp(
      attentionContainer,
      other.attentionContainer,
      t,
    )!,
    observationContainer: Color.lerp(
      observationContainer,
      other.observationContainer,
      t,
    )!,
    transparent: Color.lerp(transparent, other.transparent, t)!,
    shadow: Color.lerp(shadow, other.shadow, t)!,
    scrim: Color.lerp(scrim, other.scrim, t)!,
  );
}
