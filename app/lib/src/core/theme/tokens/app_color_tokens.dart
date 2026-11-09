import 'package:flutter/material.dart';

import 'primitives/app_color_primitives.dart';

@immutable
class AppColorTokens {
  const AppColorTokens({
    required this.canvas,
    required this.surface,
    required this.surfaceElevated,
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
        canvas: AppColorPrimitives.mineral100,
        surface: AppColorPrimitives.mineral50,
        surfaceElevated: AppColorPrimitives.white,
        surfaceSubtle: AppColorPrimitives.mineral200,
        onSurface: AppColorPrimitives.petroleumInk,
        onSurfaceMuted: AppColorPrimitives.petroleumMuted,
        border: AppColorPrimitives.mineral300,
        controlOutline: AppColorPrimitives.petroleumMuted,
        focusRing: AppColorPrimitives.copper700,
        primary: AppColorPrimitives.copper500,
        actionForeground: AppColorPrimitives.copper700,
        onPrimary: AppColorPrimitives.white,
        primaryContainer: AppColorPrimitives.copper100,
        onPrimaryContainer: AppColorPrimitives.copper900,
        success: AppColorPrimitives.green500,
        onSuccess: AppColorPrimitives.white,
        successContainer: AppColorPrimitives.green100,
        error: AppColorPrimitives.red500,
        errorForeground: AppColorPrimitives.red700,
        onError: AppColorPrimitives.white,
        errorContainer: AppColorPrimitives.red100,
        info: AppColorPrimitives.blue500,
        onInfo: AppColorPrimitives.white,
        infoContainer: AppColorPrimitives.blue100,
        restContainer: AppColorPrimitives.green100,
        memorizeContainer: AppColorPrimitives.memorize100,
        attentionContainer: AppColorPrimitives.attention100,
        observationContainer: AppColorPrimitives.green100,
        transparent: AppColorPrimitives.transparent,
        shadow: AppColorPrimitives.black,
        scrim: AppColorPrimitives.black,
      );

  const AppColorTokens.dark()
    : this(
        canvas: AppColorPrimitives.petroleum950,
        surface: AppColorPrimitives.petroleum900,
        surfaceElevated: AppColorPrimitives.petroleum800,
        surfaceSubtle: AppColorPrimitives.petroleum700,
        onSurface: AppColorPrimitives.mineral100,
        onSurfaceMuted: AppColorPrimitives.petroleumText,
        border: AppColorPrimitives.petroleum600,
        controlOutline: AppColorPrimitives.petroleumText,
        focusRing: AppColorPrimitives.copper300,
        primary: AppColorPrimitives.copper300,
        actionForeground: AppColorPrimitives.copper300,
        onPrimary: AppColorPrimitives.petroleumInk,
        primaryContainer: AppColorPrimitives.copper900,
        onPrimaryContainer: AppColorPrimitives.copper50,
        success: AppColorPrimitives.green300,
        onSuccess: AppColorPrimitives.petroleum950,
        successContainer: AppColorPrimitives.green900,
        error: AppColorPrimitives.red300,
        errorForeground: AppColorPrimitives.red300,
        onError: AppColorPrimitives.petroleum950,
        errorContainer: AppColorPrimitives.red900,
        info: AppColorPrimitives.blue300,
        onInfo: AppColorPrimitives.petroleum950,
        infoContainer: AppColorPrimitives.blue900,
        restContainer: AppColorPrimitives.green900,
        memorizeContainer: AppColorPrimitives.petroleum800,
        attentionContainer: AppColorPrimitives.red900,
        observationContainer: AppColorPrimitives.green900,
        transparent: AppColorPrimitives.transparent,
        shadow: AppColorPrimitives.black,
        scrim: AppColorPrimitives.black,
      );

  final Color canvas;
  final Color surface;
  final Color surfaceElevated;
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
    surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
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
