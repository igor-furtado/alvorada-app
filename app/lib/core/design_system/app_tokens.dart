import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';

import 'tokens/app_border_tokens.dart';
import 'tokens/app_color_tokens.dart';
import 'tokens/app_icon_tokens.dart';
import 'tokens/app_layout_tokens.dart';
import 'tokens/app_motion_tokens.dart';
import 'tokens/app_opacity_tokens.dart';
import 'tokens/app_spacing_tokens.dart';
import 'tokens/app_typography_tokens.dart';

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.colors,
    required this.overlayShadow,
    required this.typography,
    this.spacing = const AppSpacingTokens(),
    this.borders = const AppBorderTokens(),
    this.motion = const AppMotionTokens(),
    this.layout = const AppLayoutTokens(),
    this.icons = const AppIconTokens(),
    this.opacity = const AppOpacityTokens(),
    this.overlayBackdropBlur = 4,
    this.feedbackIconSize = 40,
    this.listItemMediaHeight = 260,
  });

  factory AppTokens.light() {
    const colors = AppColorTokens.light();
    const opacity = AppOpacityTokens();
    return AppTokens(
      colors: colors,
      overlayShadow: _overlayShadow(colors.scrim),
      typography: AppTypographyTokens.fromTokens(colors, opacity),
      opacity: opacity,
    );
  }

  factory AppTokens.dark() {
    const colors = AppColorTokens.dark();
    const opacity = AppOpacityTokens();
    return AppTokens(
      colors: colors,
      overlayShadow: _overlayShadow(colors.scrim),
      typography: AppTypographyTokens.fromTokens(colors, opacity),
      opacity: opacity,
    );
  }

  final AppColorTokens colors;
  final AppTypographyTokens typography;
  final AppSpacingTokens spacing;
  final AppBorderTokens borders;
  final List<BoxShadow> overlayShadow;
  final AppMotionTokens motion;
  final AppLayoutTokens layout;
  final AppIconTokens icons;
  final AppOpacityTokens opacity;
  final double overlayBackdropBlur;
  final double feedbackIconSize;
  final double listItemMediaHeight;

  @override
  AppTokens copyWith({
    AppColorTokens? colors,
    AppTypographyTokens? typography,
    AppSpacingTokens? spacing,
    AppBorderTokens? borders,
    List<BoxShadow>? overlayShadow,
    AppMotionTokens? motion,
    AppLayoutTokens? layout,
    AppIconTokens? icons,
    AppOpacityTokens? opacity,
    double? overlayBackdropBlur,
    double? feedbackIconSize,
    double? listItemMediaHeight,
  }) => AppTokens(
    colors: colors ?? this.colors,
    typography: typography ?? this.typography,
    spacing: spacing ?? this.spacing,
    borders: borders ?? this.borders,
    overlayShadow: overlayShadow ?? this.overlayShadow,
    motion: motion ?? this.motion,
    layout: layout ?? this.layout,
    icons: icons ?? this.icons,
    opacity: opacity ?? this.opacity,
    overlayBackdropBlur: overlayBackdropBlur ?? this.overlayBackdropBlur,
    feedbackIconSize: feedbackIconSize ?? this.feedbackIconSize,
    listItemMediaHeight: listItemMediaHeight ?? this.listItemMediaHeight,
  );

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      colors: colors.lerp(other.colors, t),
      typography: typography.lerp(other.typography, t),
      spacing: spacing.lerp(other.spacing, t),
      borders: borders.lerp(other.borders, t),
      overlayShadow: BoxShadow.lerpList(overlayShadow, other.overlayShadow, t) ?? const [],
      motion: motion.lerp(other.motion, t),
      layout: layout.lerp(other.layout, t),
      icons: icons.lerp(other.icons, t),
      opacity: opacity.lerp(other.opacity, t),
      overlayBackdropBlur: lerpDouble(overlayBackdropBlur, other.overlayBackdropBlur, t)!,
      feedbackIconSize: lerpDouble(feedbackIconSize, other.feedbackIconSize, t)!,
      listItemMediaHeight: lerpDouble(listItemMediaHeight, other.listItemMediaHeight, t)!,
    );
  }
}

List<BoxShadow> _overlayShadow(Color color) => [
  BoxShadow(
    color: color.withValues(alpha: .08),
    blurRadius: 12,
    offset: const Offset(0, 4),
  ),
];

extension AppTokensBuildContext on BuildContext {
  AppTokens get tokens {
    final value = Theme.of(this).extension<AppTokens>();
    assert(value != null, 'AppTokens não foi registrado no ThemeData.');
    return value!;
  }
}
