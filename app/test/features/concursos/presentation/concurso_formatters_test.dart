import 'package:estudos_app/src/features/concursos/presentation/concurso_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formata e interpreta vencimento em moeda brasileira', () {
    expect(formatBrazilianCurrency(1234567), r'R$ 12.345,67');
    expect(parseBrazilianCurrency('12.345,67'), 1234567);
    expect(parseBrazilianCurrency('1200'), 120000);
  });

  test('rejeita moeda e horários inválidos', () {
    expect(() => parseBrazilianCurrency('12,345'), throwsFormatException);
    expect(isValidTime('23:59'), isTrue);
    expect(isValidTime('24:00'), isFalse);
  });
}
