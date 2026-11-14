import 'package:estudos_app/src/features/concursos/presentation/concursos_form/concursos_form_input_formatters.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mantém apenas números nos campos inteiros', () {
    expect(_format(concursoIntegerInputFormatter, '12 vagas'), '12');
  });

  test('aplica máscara contábil brasileira ao vencimento', () {
    expect(_format(concursoCurrencyInputFormatter, '1'), '0,01');
    expect(_format(concursoCurrencyInputFormatter, '1234567'), '12.345,67');
    expect(_format(concursoCurrencyInputFormatter, r'R$ 12.345,67'), '12.345,67');
  });

  test('aplica máscaras numéricas de data e horário', () {
    expect(_format(concursoDateInputFormatter, '21122027'), '21/12/2027');
    expect(_format(concursoDateInputFormatter, '21a12b2027'), '21/12/2027');
    expect(_format(concursoTimeInputFormatter, '1350'), '13:50');
    expect(_format(concursoTimeInputFormatter, '13h50'), '13:50');
  });
}

String _format(TextInputFormatter formatter, String value) => formatter
    .formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      ),
    )
    .text;
