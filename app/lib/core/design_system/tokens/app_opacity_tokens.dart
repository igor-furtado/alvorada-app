import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

@immutable
class AppOpacityTokens {
  const AppOpacityTokens({
    this.disabled = .5,
    this.border = .72,
    this.hint = .78,
    this.tint = .13,
    this.tintStrong = .14,
    this.dialogBarrier = .10,
    this.drawerBarrier = .30,
  });

  final double disabled;
  final double border;
  final double hint;
  final double tint;
  final double tintStrong;
  final double dialogBarrier;
  final double drawerBarrier;

  AppOpacityTokens lerp(AppOpacityTokens other, double t) => AppOpacityTokens(
    disabled: lerpDouble(disabled, other.disabled, t)!,
    border: lerpDouble(border, other.border, t)!,
    hint: lerpDouble(hint, other.hint, t)!,
    tint: lerpDouble(tint, other.tint, t)!,
    tintStrong: lerpDouble(tintStrong, other.tintStrong, t)!,
    dialogBarrier: lerpDouble(dialogBarrier, other.dialogBarrier, t)!,
    drawerBarrier: lerpDouble(drawerBarrier, other.drawerBarrier, t)!,
  );
}
