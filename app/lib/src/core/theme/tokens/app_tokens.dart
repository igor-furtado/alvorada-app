import 'package:flutter/material.dart';

import 'app_border_tokens.dart';
import 'app_color_tokens.dart';
import 'app_elevation_tokens.dart';
import 'app_icon_tokens.dart';
import 'app_layout_tokens.dart';
import 'app_motion_tokens.dart';
import 'app_opacity_tokens.dart';
import 'app_size_tokens.dart';
import 'app_spacing_tokens.dart';

@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.colors,
    required this.elevations,
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
      elevations: AppElevationTokens.from(colors.shadow),
    );
  }

  factory AppTokens.dark() {
    const colors = AppColorTokens.dark();
    return AppTokens(
      colors: colors,
      elevations: AppElevationTokens.from(colors.shadow),
    );
  }

  final AppColorTokens colors;
  final AppSpacingTokens spacing;
  final AppBorderTokens borders;
  final AppElevationTokens elevations;
  final AppMotionTokens motion;
  final AppLayoutTokens layout;
  final AppIconTokens icons;
  final AppOpacityTokens opacity;
  final AppSizeTokens sizes;

  @override
  AppTokens copyWith({
    AppColorTokens? colors,
    AppSpacingTokens? spacing,
    AppBorderTokens? borders,
    AppElevationTokens? elevations,
    AppMotionTokens? motion,
    AppLayoutTokens? layout,
    AppIconTokens? icons,
    AppOpacityTokens? opacity,
    AppSizeTokens? sizes,
  }) => AppTokens(
    colors: colors ?? this.colors,
    spacing: spacing ?? this.spacing,
    borders: borders ?? this.borders,
    elevations: elevations ?? this.elevations,
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
      spacing: spacing.lerp(other.spacing, t),
      borders: borders.lerp(other.borders, t),
      elevations: elevations.lerp(other.elevations, t),
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
