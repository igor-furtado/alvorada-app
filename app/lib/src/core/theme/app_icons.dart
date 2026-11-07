import 'package:flutter/widgets.dart';

/// Ícones Phosphor centralizados para manter a linguagem visual consistente.
///
/// Os glifos usam as fontes distribuídas por `phosphor_flutter`. O acesso
/// direto por [IconData] evita a incompatibilidade temporária do pacote com
/// versões do Flutter em que `IconData` passou a ser uma classe final.
abstract final class AppIcons {
  static const double compact = 20;
  static const double standard = 24;
  static const double prominent = 28;

  static const String _regular = 'AlvoradaPhosphor';
  static const String _fill = 'PhosphorFill';
  static const String? _package = null;
  static const String _fillPackage = 'phosphor_flutter';

  static const today = IconData(
    0xe5b6,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const todayActive = IconData(
    0xe5b6,
    fontFamily: _fill,
    fontPackage: _fillPackage,
  );
  static const calendar = IconData(
    0xe7b4,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const calendarActive = IconData(
    0xe7b4,
    fontFamily: _fill,
    fontPackage: _fillPackage,
  );
  static const horizons = IconData(
    0xe47c,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const horizonsActive = IconData(
    0xe47c,
    fontFamily: _fill,
    fontPackage: _fillPackage,
  );
  static const reviews = IconData(
    0xe094,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const reviewsActive = IconData(
    0xe094,
    fontFamily: _fill,
    fontPackage: _fillPackage,
  );
  static const errorNotebook = IconData(
    0xe34e,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const errorNotebookActive = IconData(
    0xe34e,
    fontFamily: _fill,
    fontPackage: _fillPackage,
  );
  static const lockedTopic = IconData(
    0xe308,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const statistics = IconData(
    0xe156,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const settings = IconData(
    0xe434,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const add = IconData(
    0xe3d4,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const fromMemory = IconData(
    0xe74e,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const mockExam = IconData(
    0xe492,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const notification = IconData(
    0xe0ce,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const sunnyDays = IconData(
    0xe472,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const rest = IconData(
    0xe1c2,
    fontFamily: _regular,
    fontPackage: _package,
  );

  static const memorize = IconData(
    0xe74e,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const attention = IconData(
    0xe4e0,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const scales = IconData(
    0xe750,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const caseLaw = scales;
  static const observation = IconData(
    0xe2ce,
    fontFamily: _regular,
    fontPackage: _package,
  );

  static const book = IconData(
    0xe0e6,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const bookText = IconData(
    0xe8f2,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const questions = IconData(
    0xe182,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const play = IconData(
    0xe3d0,
    fontFamily: _fill,
    fontPackage: _fillPackage,
  );
  static const check = IconData(
    0xe182,
    fontFamily: _regular,
    fontPackage: _package,
  );
  static const arrowRight = IconData(
    0xe06c,
    fontFamily: _regular,
    fontPackage: _package,
  );
}
