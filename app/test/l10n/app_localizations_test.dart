import 'package:estudos_app/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final pt = lookupAppLocalizations(const Locale('pt'));
  final en = lookupAppLocalizations(const Locale('en'));

  test('resolve textos genéricos nos locales suportados', () {
    expect(pt.close, 'Fechar');
    expect(pt.search, 'Buscar');
    expect(en.close, 'Close');
    expect(en.search, 'Search');
  });

  test('aplica pluralização ICU em vez de concatenar fragmentos', () {
    expect(pt.nextExamIn(1), 'A próxima prova é em 1 dia');
    expect(pt.nextExamIn(2), 'A próxima prova é em 2 dias');
    expect(en.loadedItems(1), '1 result loaded.');
    expect(en.loadedItems(2), '2 results loaded.');
  });
}
