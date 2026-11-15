import 'package:estudos_app/features/concursos/presentation/concurso_formatters.dart';
import 'package:estudos_app/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  final pt = lookupAppLocalizations(const Locale('pt'));

  setUpAll(() async {
    await initializeDateFormatting('pt');
    await initializeDateFormatting('en');
  });

  test('formata e interpreta vencimento em moeda brasileira', () {
    expect(formatCurrency(1234567, pt), contains('12.345,67'));
    expect(parseBrazilianCurrency('12.345,67'), 1234567);
    expect(parseBrazilianCurrency('1200'), 120000);
  });

  test('formata apresentação conforme o locale', () {
    final en = lookupAppLocalizations(const Locale('en'));

    expect(formatExamDate(DateTime(2026, 12, 13), pt), '13 de dez. de 2026');
    expect(formatExamDate(DateTime(2026, 12, 13), en), 'Dec 13, 2026');
  });

  test('rejeita moeda e horários inválidos', () {
    expect(() => parseBrazilianCurrency('12,345'), throwsFormatException);
    expect(isValidTime('23:59'), isTrue);
    expect(isValidTime('24:00'), isFalse);
  });
}
