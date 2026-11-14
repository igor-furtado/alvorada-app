import 'package:estudos_app/src/features/concursos/presentation/concursos_form/concursos_form_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('valida limites dos campos numéricos', () {
    expect(ConcursosFormValidators.nonNegativeInteger('100'), isNull);
    expect(ConcursosFormValidators.nonNegativeInteger('1000001'), isNotNull);
    expect(ConcursosFormValidators.weeklyWorkload('40'), isNull);
    expect(ConcursosFormValidators.weeklyWorkload('169'), isNotNull);
  });

  test('valida data real e intervalo de horários', () {
    expect(ConcursosFormValidators.examDate('29/02/2028'), isNull);
    expect(ConcursosFormValidators.examDate('29/02/2027'), isNotNull);
    expect(ConcursosFormValidators.examTimeRange('13:00', '18:00'), isNull);
    expect(ConcursosFormValidators.examTimeRange('18:00', '13:00'), isNotNull);
    expect(ConcursosFormValidators.examTimeRange('13:00', ''), isNotNull);
  });
}
