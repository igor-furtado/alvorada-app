import 'package:estudos_app/src/core/theme/app_icons.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ícones da interface usam a família visual Phosphor Light', () {
    const icons = <IconData>[
      AppIcons.chevronLeft,
      AppIcons.chevronRight,
      AppIcons.edit,
      AppIcons.expandMore,
      AppIcons.expandNext,
      AppIcons.event,
      AppIcons.institution,
      AppIcons.delete,
      AppIcons.sortAscending,
      AppIcons.sortDescending,
      AppIcons.search,
      AppIcons.close,
    ];

    for (final icon in icons) {
      expect(icon.fontFamily, 'AlvoradaPhosphor');
      expect(icon.fontPackage, isNull);
    }
  });
}
