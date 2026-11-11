import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';

@immutable
class AppOpacityTokens {
  const AppOpacityTokens({
    this.disabled = .38,
    this.selectionFaint = .28,
    this.selection = .42,
    this.subtle = .48,
    this.half = .5,
    this.muted = .55,
    this.border = .72,
    this.hint = .78,
    this.tint = .13,
    this.tintStrong = .14,
    this.dialogBarrier = .10,
    this.drawerBarrier = .30,
  });

  final double disabled;
  final double selectionFaint;
  final double selection;
  final double subtle;
  final double half;
  final double muted;
  final double border;
  final double hint;
  final double tint;
  final double tintStrong;
  final double dialogBarrier;
  final double drawerBarrier;

  AppOpacityTokens lerp(AppOpacityTokens other, double t) => AppOpacityTokens(
    disabled: lerpDouble(disabled, other.disabled, t)!,
    selectionFaint: lerpDouble(selectionFaint, other.selectionFaint, t)!,
    selection: lerpDouble(selection, other.selection, t)!,
    subtle: lerpDouble(subtle, other.subtle, t)!,
    half: lerpDouble(half, other.half, t)!,
    muted: lerpDouble(muted, other.muted, t)!,
    border: lerpDouble(border, other.border, t)!,
    hint: lerpDouble(hint, other.hint, t)!,
    tint: lerpDouble(tint, other.tint, t)!,
    tintStrong: lerpDouble(tintStrong, other.tintStrong, t)!,
    dialogBarrier: lerpDouble(dialogBarrier, other.dialogBarrier, t)!,
    drawerBarrier: lerpDouble(drawerBarrier, other.drawerBarrier, t)!,
  );
}
