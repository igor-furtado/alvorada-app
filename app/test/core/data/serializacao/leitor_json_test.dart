import 'package:estudos_app/src/core/data/serializacao/leitor_json.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const json = <String, Object?>{
    'texto': 'valor',
    'inteiro': 3,
    'booleano': true,
    'objetos': [
      {'id': '1'},
    ],
  };

  test('lê valores tipados do JSON', () {
    expect(readJsonString(json, 'texto'), 'valor');
    expect(readJsonNullableString(json, 'nulo'), isNull);
    expect(readJsonInteger(json, 'inteiro'), 3);
    expect(readJsonBoolean(json, 'booleano'), isTrue);
    expect(readJsonList(json, 'objetos'), [
      {'id': '1'},
    ]);
  });

  test('rejeita texto anulável com tipo inesperado', () {
    expect(
      () => readJsonNullableString(const {'campo': 1}, 'campo'),
      throwsA(isA<FormatException>()),
    );
  });

  test('lê inteiro anulável', () {
    expect(readJsonNullableInteger({'vagas': 10}, 'vagas'), 10);
    expect(readJsonNullableInteger({'vagas': null}, 'vagas'), isNull);
    expect(
      () => readJsonNullableInteger({'vagas': 'dez'}, 'vagas'),
      throwsFormatException,
    );
  });

  test('informa o campo quando o tipo recebido é inválido', () {
    expect(
      () => readJsonInteger(json, 'texto'),
      throwsA(isA<FormatException>().having((error) => error.message, 'message', contains('texto'))),
    );
  });

  test('rejeita itens que não sejam objetos', () {
    expect(
      () => readJsonList(const {
        'itens': [1],
      }, 'itens'),
      throwsA(isA<FormatException>().having((error) => error.message, 'message', contains('itens'))),
    );
  });
}
