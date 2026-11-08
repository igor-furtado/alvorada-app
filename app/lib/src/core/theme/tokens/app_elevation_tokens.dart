import 'package:flutter/material.dart';

@immutable
class AppElevationTokens {
  const AppElevationTokens({
    required this.none,
    required this.low,
    required this.medium,
    required this.high,
  });

  factory AppElevationTokens.from(Color shadow) => AppElevationTokens(
    none: const [],
    low: [
      BoxShadow(
        color: shadow.withValues(alpha: .05),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
    medium: [
      BoxShadow(
        color: shadow.withValues(alpha: .08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
    high: [
      BoxShadow(
        color: shadow.withValues(alpha: .12),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  );

  final List<BoxShadow> none;
  final List<BoxShadow> low;
  final List<BoxShadow> medium;
  final List<BoxShadow> high;

  AppElevationTokens lerp(AppElevationTokens other, double t) => AppElevationTokens(
    none: BoxShadow.lerpList(none, other.none, t) ?? const [],
    low: BoxShadow.lerpList(low, other.low, t) ?? const [],
    medium: BoxShadow.lerpList(medium, other.medium, t) ?? const [],
    high: BoxShadow.lerpList(high, other.high, t) ?? const [],
  );
}
