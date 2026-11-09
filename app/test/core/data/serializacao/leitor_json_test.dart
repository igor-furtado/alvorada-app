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
    expect(readJsonInteger(json, 'inteiro'), 3);
    expect(readJsonBoolean(json, 'booleano'), isTrue);
    expect(readJsonList(json, 'objetos'), [
      {'id': '1'},
    ]);
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
