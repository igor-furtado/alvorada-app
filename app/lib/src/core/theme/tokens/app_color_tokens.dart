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
        canvas: AppColorPrimitives.paper100,
        surface: AppColorPrimitives.paper50,
        surfaceElevated: AppColorPrimitives.paper50,
        surfaceSubtle: AppColorPrimitives.paper200,
        onSurface: AppColorPrimitives.ink900,
        onSurfaceMuted: AppColorPrimitives.ink700,
        border: AppColorPrimitives.paper300,
        controlOutline: AppColorPrimitives.ink700,
        focusRing: AppColorPrimitives.orange900,
        primary: AppColorPrimitives.orange500,
        actionForeground: AppColorPrimitives.orange900,
        onPrimary: AppColorPrimitives.ink900,
        primaryContainer: AppColorPrimitives.orange100,
        onPrimaryContainer: AppColorPrimitives.ink900,
        success: AppColorPrimitives.sage700,
        onSuccess: AppColorPrimitives.white,
        successContainer: AppColorPrimitives.sage200,
        error: AppColorPrimitives.red500,
        errorForeground: AppColorPrimitives.red700,
        onError: AppColorPrimitives.white,
        errorContainer: AppColorPrimitives.red100,
        info: AppColorPrimitives.violet600,
        onInfo: AppColorPrimitives.white,
        infoContainer: AppColorPrimitives.violet100,
        restContainer: AppColorPrimitives.sage200,
        memorizeContainer: AppColorPrimitives.memorize100,
        attentionContainer: AppColorPrimitives.attention100,
        observationContainer: AppColorPrimitives.sage100,
        transparent: AppColorPrimitives.transparent,
        shadow: AppColorPrimitives.black,
        scrim: AppColorPrimitives.black,
      );

  const AppColorTokens.dark()
    : this(
        canvas: AppColorPrimitives.night950,
        surface: AppColorPrimitives.night900,
        surfaceElevated: AppColorPrimitives.night800,
        surfaceSubtle: AppColorPrimitives.night800,
        onSurface: AppColorPrimitives.paper100,
        onSurfaceMuted: AppColorPrimitives.nightText,
        border: AppColorPrimitives.night700,
        controlOutline: AppColorPrimitives.nightText,
        focusRing: AppColorPrimitives.orange400,
        primary: AppColorPrimitives.orange400,
        actionForeground: AppColorPrimitives.orange400,
        onPrimary: AppColorPrimitives.ink900,
        primaryContainer: AppColorPrimitives.orange900,
        onPrimaryContainer: AppColorPrimitives.paper100,
        success: AppColorPrimitives.sage300,
        onSuccess: AppColorPrimitives.night950,
        successContainer: AppColorPrimitives.nightSage,
        error: AppColorPrimitives.red300,
        errorForeground: AppColorPrimitives.red300,
        onError: AppColorPrimitives.night950,
        errorContainer: AppColorPrimitives.night800,
        info: AppColorPrimitives.violet300,
        onInfo: AppColorPrimitives.night950,
        infoContainer: AppColorPrimitives.night800,
        restContainer: AppColorPrimitives.nightSage,
        memorizeContainer: AppColorPrimitives.night800,
        attentionContainer: AppColorPrimitives.night800,
        observationContainer: AppColorPrimitives.nightSage,
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
