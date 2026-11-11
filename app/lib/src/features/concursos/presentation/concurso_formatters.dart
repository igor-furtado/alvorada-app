import '../../../core/content/app_messages.dart';

const _months = ['jan.', 'fev.', 'mar.', 'abr.', 'mai.', 'jun.', 'jul.', 'ago.', 'set.', 'out.', 'nov.', 'dez.'];

String formatExamDate(DateTime? value) {
  if (value == null) return AppMessages.toBeDefined;
  return '${value.day} ${_months[value.month - 1]} ${value.year}';
}

String formatBoard(String? value) => value ?? AppMessages.toBeDefined;

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
