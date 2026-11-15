import 'package:estudos_app/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

String formatExamDate(DateTime? value, AppLocalizations l10n) {
  if (value == null) return l10n.toBeDefined;
  return DateFormat.yMMMd(l10n.localeName).format(value);
}

String formatBoard(String? value, AppLocalizations l10n) => value ?? l10n.toBeDefined;

String formatBrazilianInputDate(DateTime? value) {
  if (value == null) return '';
  return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year.toString().padLeft(4, '0')}';
}

String formatCurrency(int? cents, AppLocalizations l10n) {
  if (cents == null) return l10n.toBeDefined;
  return NumberFormat.simpleCurrency(locale: l10n.localeName, name: 'BRL').format(cents / 100);
}

String formatBrazilianCurrencyInput(int? cents) {
  if (cents == null) return '';
  final whole = cents ~/ 100;
  final decimal = (cents % 100).toString().padLeft(2, '0');
  final digits = whole.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write('.');
    buffer.write(digits[index]);
  }
  return '$buffer,$decimal';
}

int? parseBrazilianCurrency(String value) {
  var normalized = value.trim().replaceAll(r'R$', '').replaceAll(' ', '');
  if (normalized.isEmpty) return null;
  normalized = normalized.replaceAll('.', '');
  final parts = normalized.split(',');
  if (parts.length > 2 || parts.first.isEmpty || !RegExp(r'^\d+$').hasMatch(parts.first)) {
    throw const FormatException();
  }
  final decimals = parts.length == 1 ? '' : parts[1];
  if (decimals.length > 2 || (decimals.isNotEmpty && !RegExp(r'^\d+$').hasMatch(decimals))) {
    throw const FormatException();
  }
  return int.parse(parts.first) * 100 + int.parse(decimals.padRight(2, '0').isEmpty ? '0' : decimals.padRight(2, '0'));
}

int? parseOptionalInteger(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return null;
  final parsed = int.tryParse(normalized);
  if (parsed == null || parsed < 0) throw const FormatException();
  return parsed;
}

bool isValidTime(String value) {
  final normalized = value.trim();
  final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(normalized);
  if (match == null) return false;
  return int.parse(match.group(1)!) <= 23 && int.parse(match.group(2)!) <= 59;
}

String formatExamTimeRange(String? start, String? end, AppLocalizations l10n) {
  if (start == null || end == null) return l10n.toBeDefined;
  return '$start–$end';
}

DateTime? parseBrazilianDate(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return null;
  final parts = normalized.split('/');
  if (parts.length != 3) throw const FormatException();
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) throw const FormatException();
  final parsed = DateTime(year, month, day);
  if (parsed.day != day || parsed.month != month || parsed.year != year) {
    throw const FormatException();
  }
  return parsed;
}
