import 'dart:io';

import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('mantém decisões transversais diretamente no tema', () {
    final tokens = AppTokens.light();

    expect(tokens.overlayShadow, hasLength(1));
    expect(tokens.overlayBackdropBlur, 4);
    expect(tokens.feedbackIconSize, 40);
    expect(tokens.listItemMediaHeight, 260);
  });

  test('interpola dimensões compartilhadas', () {
    final start = AppTokens.light().copyWith(
      overlayBackdropBlur: 2,
      feedbackIconSize: 32,
      listItemMediaHeight: 200,
    );
    final end = AppTokens.dark().copyWith(
      overlayBackdropBlur: 6,
      feedbackIconSize: 48,
      listItemMediaHeight: 300,
    );

    final middle = start.lerp(end, .5);

    expect(middle.overlayBackdropBlur, 4);
    expect(middle.feedbackIconSize, 40);
    expect(middle.listItemMediaHeight, 250);
  });

  test('expõe variações tipográficas semânticas completas', () {
    final tokens = AppTokens.light();

    expect(tokens.typography.buttonPrimary.color, tokens.colors.onPrimary);
    expect(tokens.typography.button.fontWeight, FontWeight.w600);
    expect(tokens.typography.errorText.color, tokens.colors.error);
    expect(tokens.typography.successLabel.color, tokens.colors.success);
    expect(tokens.typography.disciplineSelected.fontWeight, FontWeight.w700);
    expect(tokens.typography.disciplineUnselected.color, tokens.colors.onSurfaceMuted);
    expect(tokens.typography.contentTitleCompleted.decoration, TextDecoration.lineThrough);
    expect(tokens.typography.navigationBrand.fontWeight, FontWeight.w700);
    expect(tokens.typography.weekPageTitle.fontSize, 34);
    expect(tokens.typography.weekPrimaryAction.fontWeight, FontWeight.w700);
    expect(tokens.typography.weekCardTitleCompleted.decoration, TextDecoration.lineThrough);
  });

  test('widgets não derivam variantes tipográficas localmente', () {
    final allowed = {
      'lib/core/design_system/app_typography.dart',
      'lib/core/design_system/tokens/app_typography_tokens.dart',
    };
    final typographyCopyWith = RegExp(
      r'(?:typography|textTheme)\.[A-Za-z0-9_]+\??[\s\S]{0,180}?\.copyWith\(',
    );
    final violations = <String>[];

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart') || allowed.contains(entity.path)) {
        continue;
      }
      if (typographyCopyWith.hasMatch(entity.readAsStringSync())) {
        violations.add(entity.path);
      }
    }

    expect(
      violations,
      isEmpty,
      reason: 'Use um estilo semântico pronto de AppTypographyTokens: $violations',
    );
  });
}
