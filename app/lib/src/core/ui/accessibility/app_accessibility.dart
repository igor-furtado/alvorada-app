import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

abstract final class AppAccessibility {
  static double contrastRatio(Color foreground, Color background) {
    final foregroundLuminance = foreground.computeLuminance();
    final backgroundLuminance = background.computeLuminance();
    final lighter = foregroundLuminance > backgroundLuminance ? foregroundLuminance : backgroundLuminance;
    final darker = foregroundLuminance > backgroundLuminance ? backgroundLuminance : foregroundLuminance;
    return (lighter + 0.05) / (darker + 0.05);
  }

  static bool meetsTextAA(Color foreground, Color background, {bool largeText = false}) =>
      contrastRatio(foreground, background) >= (largeText ? 3 : 4.5);

  static bool meetsComponentAA(Color foreground, Color background) => contrastRatio(foreground, background) >= 3;

  static void announce(BuildContext context, String message, {Assertiveness assertiveness = Assertiveness.polite}) {
    if (!MediaQuery.supportsAnnounceOf(context)) return;
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        message,
        Directionality.of(context),
        assertiveness: assertiveness,
      ),
    );
  }
}
