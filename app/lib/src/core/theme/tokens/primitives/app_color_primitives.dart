import 'package:flutter/material.dart';

/// Valores cromáticos brutos do sistema. Widgets não devem acessar esta classe.
abstract final class AppColorPrimitives {
  static const zinc50 = Color(0xFFFAFAFA);
  static const zinc100 = Color(0xFFF4F4F5);
  static const zinc200 = Color(0xFFE4E4E7);
  static const zinc300 = Color(0xFFD4D4D8);
  static const zinc400 = Color(0xFFA1A1AA);
  static const zinc500 = Color(0xFF71717A);
  static const zinc600 = Color(0xFF52525B);
  static const zinc700 = Color(0xFF3F3F46);
  static const zinc800 = Color(0xFF27272A);
  static const zinc900 = Color(0xFF18181B);
  static const zinc950 = Color(0xFF09090B);

  static const red50 = Color(0xFFFEF2F2);
  static const red300 = Color(0xFFFCA5A5);
  static const red600 = Color(0xFFDC2626);
  static const red700 = Color(0xFFB91C1C);
  static const red950 = Color(0xFF450A0A);
  static const redDestructiveLight = Color(0xFFE7000B);
  static const redDestructiveDark = Color(0xFFFF6467);
  static const redDestructiveContainerLight = Color(0xFFFDE6E7);
  static const redDestructiveContainerDark = Color(0xFF46272A);

  static const green50 = Color(0xFFF0FDF4);
  static const green300 = Color(0xFF86EFAC);
  static const green700 = Color(0xFF15803D);
  static const green950 = Color(0xFF052E16);

  static const blue50 = Color(0xFFEFF6FF);
  static const blue300 = Color(0xFF93C5FD);
  static const blue700 = Color(0xFF1D4ED8);
  static const blue950 = Color(0xFF172554);

  static const amber50 = Color(0xFFFFFBEB);
  static const amber200 = Color(0xFFFDE68A);
  static const amber900 = Color(0xFF78350F);
  static const amber950 = Color(0xFF451A03);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const transparent = Color(0x00000000);
}
