import 'package:estudos_app/src/core/theme/tokens/app_size_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('interpola os tamanhos semânticos da tela de Concurso', () {
    const start = AppSizeTokens(summaryRail: 200, searchField: 240, disciplineRowHeight: 60);
    const end = AppSizeTokens(summaryRail: 300, searchField: 320, disciplineRowHeight: 76);

    final middle = start.lerp(end, .5);

    expect(middle.summaryRail, 250);
    expect(middle.searchField, 280);
    expect(middle.disciplineRowHeight, 68);
  });
}
