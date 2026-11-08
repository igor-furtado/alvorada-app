import 'package:estudos_app/src/core/theme/app_theme.dart';
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
