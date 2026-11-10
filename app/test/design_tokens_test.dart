import 'dart:io';

import 'package:estudos_app/src/core/theme/app_theme.dart';
import 'package:estudos_app/src/core/theme/app_typography.dart';
import 'package:estudos_app/src/core/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('widgets não acessam cores ou tipografia diretamente pelo Theme', () {
    final forbidden = RegExp(
      r'Theme\.of\s*\([^)]*\)\s*\.\s*(colorScheme|textTheme)',
      multiLine: true,
    );
    final violations = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final source = entity.readAsStringSync();
      if (forbidden.hasMatch(source)) {
        violations.add(entity.path);
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  group('AppTokens', () {
    test('não expõe escala de elevação', () {
      final source = File('lib/src/core/theme/tokens/app_tokens.dart').readAsStringSync();
      final shadowSource = File(
        'lib/src/core/theme/tokens/app_shadow_tokens.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('elevations')));
      expect(
        File('lib/src/core/theme/tokens/app_color_tokens.dart').readAsStringSync(),
        isNot(contains('surfaceElevated')),
      );
      expect(
        File('lib/src/core/theme/tokens/app_elevation_tokens.dart').existsSync(),
        isFalse,
      );
      expect(
        RegExp(r'final List<BoxShadow> (\w+);').allMatches(shadowSource).map((match) => match.group(1)),
        ['overlay'],
      );
    });

    test('restringe sombras a superfícies de overlay', () {
      final constructors = <String>[];
      final consumers = <String>[];

      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = entity.readAsStringSync();
        if (source.contains('BoxShadow(')) constructors.add(entity.path);
        if (source.contains('boxShadow:')) {
          if (!source.contains('tokens.shadows.overlay')) {
            consumers.add(entity.path);
          }
        }
      }

      expect(constructors, ['lib/src/core/theme/tokens/app_shadow_tokens.dart']);
      expect(consumers, isEmpty, reason: consumers.join('\n'));
    });

    test('expõe valores semânticos diferentes por tema', () {
      final light = AppTokens.light();
      final dark = AppTokens.dark();

      expect(light.colors.canvas, isNot(dark.colors.canvas));
      expect(light.colors.onSurface, isNot(dark.colors.onSurface));
      expect(light.spacing.lg, dark.spacing.lg);
    });

    test('fixa a identidade shadcn zinc aprovada', () {
      final light = AppTokens.light();
      final dark = AppTokens.dark();

      expect(light.colors.canvas, const Color(0xFFFAFAFA));
      expect(light.colors.card, const Color(0xFFFFFFFF));
      expect(light.colors.popover, const Color(0xFFFFFFFF));
      expect(light.colors.primary, const Color(0xFF18181B));
      expect(light.colors.border, const Color(0xFFE4E4E7));
      expect(light.colors.error, const Color(0xFFE7000B));
      expect(light.colors.errorContainer, const Color(0xFFFDE6E7));
      expect(light.colors.warning, const Color(0xFF78350F));
      expect(light.colors.warningContainer, const Color(0xFFFFFBEB));
      expect(light.colors.warningBorder, const Color(0xFFFDE68A));
      expect(dark.colors.canvas, const Color(0xFF09090B));
      expect(dark.colors.card, const Color(0xFF18181B));
      expect(dark.colors.popover, const Color(0xFF18181B));
      expect(dark.colors.error, const Color(0xFFFF6467));
      expect(dark.colors.errorContainer, const Color(0xFF46272A));
      expect(dark.colors.warning, const Color(0xFFFFFBEB));
      expect(dark.colors.warningContainer, const Color(0xFF451A03));
      expect(dark.colors.warningBorder, const Color(0xFF78350F));
      expect(AppTypography.bodyFamily, 'Geist');
      expect(AppTypography.displayFamily, 'Geist');
      expect(light.typography.headlineLarge.fontFamily, isNotEmpty);
      expect(light.typography.button.fontWeight, FontWeight.w500);
      expect(light.layout.controlHeight, 32);
      expect(light.layout.buttonHeightSm, 28);
      expect(light.layout.buttonHeightMd, 32);
      expect(light.layout.buttonHeightLg, 36);
      expect(light.sizes.avatarSm, 24);
      expect(light.sizes.avatarMd, 32);
      expect(light.sizes.avatarLg, 40);
      expect(light.opacity.dialogBarrier, .10);
      expect(light.sizes.dialogBackdropBlur, 4);
      expect(light.shadows.overlay, isNotEmpty);
      expect(
        AppTheme.light.dialogTheme.barrierColor,
        light.colors.scrim.withValues(alpha: light.opacity.dialogBarrier),
      );
    });

    test('copyWith preserva categorias não substituídas', () {
      final tokens = AppTokens.light();
      const spacing = AppSpacingTokens(lg: 18);

      final changed = tokens.copyWith(spacing: spacing);

      expect(changed.spacing.lg, 18);
      expect(changed.colors, same(tokens.colors));
      expect(changed.borders, same(tokens.borders));
      expect(changed.shadows, same(tokens.shadows));
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
          (colors.warning, colors.warningContainer),
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
