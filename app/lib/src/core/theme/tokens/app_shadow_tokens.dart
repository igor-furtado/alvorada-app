import 'package:flutter/material.dart';

/// Sombras semânticas restritas a superfícies flutuantes.
///
/// O design system não modela profundidade por níveis de elevação. Cards,
/// controles e regiões de layout permanecem planos e separados por superfície,
/// borda e raio.
@immutable
class AppShadowTokens {
  const AppShadowTokens({required this.overlay});

  factory AppShadowTokens.from(Color shadow) => AppShadowTokens(
    overlay: [
      BoxShadow(
        color: shadow.withValues(alpha: .08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  final List<BoxShadow> overlay;

  AppShadowTokens lerp(AppShadowTokens other, double t) => AppShadowTokens(
    overlay: BoxShadow.lerpList(overlay, other.overlay, t) ?? const [],
  );
}
