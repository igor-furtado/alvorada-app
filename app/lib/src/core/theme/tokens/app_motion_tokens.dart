import 'package:flutter/material.dart';

@immutable
class AppMotionTokens {
  const AppMotionTokens({
    this.fast = const Duration(milliseconds: 120),
    this.medium = const Duration(milliseconds: 240),
    this.slow = const Duration(milliseconds: 400),
    this.drawer = const Duration(milliseconds: 450),
    this.standard = Curves.easeInOutCubic,
    this.enter = Curves.easeOutCubic,
    this.exit = Curves.easeInCubic,
    this.drawerEnter = const Cubic(.22, 1, .36, 1),
  });

  final Duration fast;
  final Duration medium;
  final Duration slow;
  final Duration drawer;
  final Curve standard;
  final Curve enter;
  final Curve exit;
  final Curve drawerEnter;

  AppMotionTokens lerp(AppMotionTokens other, double t) => t < .5 ? this : other;
}
