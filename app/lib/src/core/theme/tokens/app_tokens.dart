import 'package:flutter/material.dart';

import 'app_border_tokens.dart';
import 'app_color_tokens.dart';
import 'app_icon_tokens.dart';
import 'app_layout_tokens.dart';
import 'app_motion_tokens.dart';
import 'app_opacity_tokens.dart';
import 'app_shadow_tokens.dart';
import 'app_size_tokens.dart';
import 'app_spacing_tokens.dart';
import 'app_typography_tokens.dart';

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.colors,
    required this.shadows,
    required this.typography,
    this.spacing = const AppSpacingTokens(),
    this.borders = const AppBorderTokens(),
    this.motion = const AppMotionTokens(),
    this.layout = const AppLayoutTokens(),
    this.icons = const AppIconTokens(),
    this.opacity = const AppOpacityTokens(),
    this.sizes = const AppSizeTokens(),
  });

  factory AppTokens.light() {
    const colors = AppColorTokens.light();
    return AppTokens(
      colors: colors,
      shadows: AppShadowTokens.from(colors.shadow),
      typography: AppTypographyTokens.fromColors(colors.onSurface, colors.onSurfaceMuted),
    );
  }

  factory AppTokens.dark() {
    const colors = AppColorTokens.dark();
    return AppTokens(
      colors: colors,
      shadows: AppShadowTokens.from(colors.shadow),
      typography: AppTypographyTokens.fromColors(colors.onSurface, colors.onSurfaceMuted),
    );
  }

  final AppColorTokens colors;
  final AppTypographyTokens typography;
  final AppSpacingTokens spacing;
  final AppBorderTokens borders;
  final AppShadowTokens shadows;
  final AppMotionTokens motion;
  final AppLayoutTokens layout;
  final AppIconTokens icons;
  final AppOpacityTokens opacity;
  final AppSizeTokens sizes;

  @override
  AppTokens copyWith({
    AppColorTokens? colors,
    AppTypographyTokens? typography,
    AppSpacingTokens? spacing,
    AppBorderTokens? borders,
    AppShadowTokens? shadows,
    AppMotionTokens? motion,
    AppLayoutTokens? layout,
    AppIconTokens? icons,
    AppOpacityTokens? opacity,
    AppSizeTokens? sizes,
  }) => AppTokens(
    colors: colors ?? this.colors,
    typography: typography ?? this.typography,
    spacing: spacing ?? this.spacing,
    borders: borders ?? this.borders,
    shadows: shadows ?? this.shadows,
    motion: motion ?? this.motion,
    layout: layout ?? this.layout,
    icons: icons ?? this.icons,
    opacity: opacity ?? this.opacity,
    sizes: sizes ?? this.sizes,
  );

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      colors: colors.lerp(other.colors, t),
      typography: typography.lerp(other.typography, t),
      spacing: spacing.lerp(other.spacing, t),
      borders: borders.lerp(other.borders, t),
      shadows: shadows.lerp(other.shadows, t),
      motion: motion.lerp(other.motion, t),
      layout: layout.lerp(other.layout, t),
      icons: icons.lerp(other.icons, t),
      opacity: opacity.lerp(other.opacity, t),
      sizes: sizes.lerp(other.sizes, t),
    );
  }
}

extension AppTokensBuildContext on BuildContext {
  AppTokens get tokens {
    final value = Theme.of(this).extension<AppTokens>();
    assert(value != null, 'AppTokens não foi registrado no ThemeData.');
    return value!;
  }
}
