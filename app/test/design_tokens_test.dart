import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTokens', () {
    test('expõe valores semânticos diferentes por tema', () {
      final light = AppTokens.light();
      final dark = AppTokens.dark();

      expect(light.colors.canvas, isNot(dark.colors.canvas));
      expect(light.colors.onSurface, isNot(dark.colors.onSurface));
      expect(light.spacing.lg, dark.spacing.lg);
    });

    test('copyWith preserva categorias não substituídas', () {
      final tokens = AppTokens.light();
      const spacing = AppSpacingTokens(lg: 18);

      final changed = tokens.copyWith(spacing: spacing);

      expect(changed.spacing.lg, 18);
      expect(changed.colors, same(tokens.colors));
      expect(changed.borders, same(tokens.borders));
    });

    test('lerp interpola tokens durante a troca de tema', () {
      final light = AppTokens.light();
      final dark = AppTokens.dark();
      final middle = light.lerp(dark, .5);

      expect(
        middle.colors.canvas,
        Color.lerp(light.colors.canvas, dark.colors.canvas, .5),
      );
      expect(middle.spacing.lg, light.spacing.lg);
    });

    test('cores funcionais atendem contraste WCAG AA', () {
      for (final tokens in [AppTokens.light(), AppTokens.dark()]) {
        final colors = tokens.colors;
        final textCombinations = [
          (colors.onSurface, colors.surface),
          (colors.onSurfaceMuted, colors.surface),
          (colors.onPrimary, colors.primary),
          (colors.onPrimaryContainer, colors.primaryContainer),
          (colors.onSuccess, colors.success),
          (colors.success, colors.successContainer),
          (colors.onError, colors.error),
          (colors.onSurface, colors.errorContainer),
          (colors.onInfo, colors.info),
          (colors.info, colors.infoContainer),
          (colors.actionForeground, colors.surface),
          (colors.errorForeground, colors.errorContainer),
        ];
        for (final (foreground, background) in textCombinations) {
          expect(AppAccessibility.contrastRatio(foreground, background), greaterThanOrEqualTo(4.5));
        }
        for (final foreground in [colors.controlOutline, colors.focusRing]) {
          expect(AppAccessibility.contrastRatio(foreground, colors.surface), greaterThanOrEqualTo(3));
        }
      }
    });

    testWidgets('fica acessível pelo BuildContext', (tester) async {
      late AppTokens tokens;
      final expected = AppTokens.light();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [expected]),
          home: Builder(
            builder: (context) {
              tokens = context.tokens;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(tokens, same(expected));
    });
  });
}
