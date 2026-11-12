String readJsonString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String) return value;
  throw FormatException('O campo "$key" da API deve ser um texto.');
}

String? readJsonNullableString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null || value is String) return value as String?;
  throw FormatException('O campo "$key" da API deve ser um texto ou nulo.');
}

int readJsonInteger(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int) return value;
  throw FormatException(
    'O campo "$key" da API deve ser um número inteiro.',
  );
}

int? readJsonNullableInteger(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null || value is int) return value as int?;
  throw FormatException(
    'O campo "$key" da API deve ser um número inteiro ou nulo.',
  );
}

bool readJsonBoolean(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is bool) return value;
  throw FormatException(
    'O campo "$key" da API deve ser verdadeiro ou falso.',
  );
}

List<Map<String, Object?>> readJsonList(
  Map<String, Object?> json,
  String key,
) {
  final value = json[key];
  if (value is! List<Object?>) {
    throw FormatException('O campo "$key" da API deve ser uma lista.');
  }
  return value
      .map((item) {
        if (item is Map<String, Object?>) return item;
        throw FormatException(
          'Os itens de "$key" da API devem ser objetos.',
        );
      })
      .toList(growable: false);
}
