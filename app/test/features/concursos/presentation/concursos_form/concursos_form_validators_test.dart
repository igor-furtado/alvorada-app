import 'package:estudos_app/features/concursos/presentation/concursos_form/concursos_form_validators.dart';
import 'package:estudos_app/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('pt'));

  test('valida limites dos campos numéricos', () {
    expect(ConcursosFormValidators.nonNegativeInteger('100', l10n), isNull);
    expect(ConcursosFormValidators.nonNegativeInteger('1000001', l10n), isNotNull);
    expect(ConcursosFormValidators.weeklyWorkload('40', l10n), isNull);
    expect(ConcursosFormValidators.weeklyWorkload('169', l10n), isNotNull);
  });

  test('valida data real e intervalo de horários', () {
    expect(ConcursosFormValidators.examDate('29/02/2028', l10n), isNull);
    expect(ConcursosFormValidators.examDate('29/02/2027', l10n), isNotNull);
    expect(ConcursosFormValidators.examTimeRange('13:00', '18:00', l10n), isNull);
    expect(ConcursosFormValidators.examTimeRange('18:00', '13:00', l10n), isNotNull);
    expect(ConcursosFormValidators.examTimeRange('13:00', '', l10n), isNotNull);
  });
}
