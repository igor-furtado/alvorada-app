import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
