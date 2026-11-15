import 'package:flutter/services.dart';

import '../concurso_formatters.dart';

final TextInputFormatter concursoIntegerInputFormatter = FilteringTextInputFormatter.digitsOnly;
final TextInputFormatter concursoDateInputFormatter = _FixedDigitsMaskFormatter(
  maxDigits: 8,
  separator: '/',
  groupLengths: const [2, 2, 4],
);
final TextInputFormatter concursoTimeInputFormatter = _FixedDigitsMaskFormatter(
  maxDigits: 4,
  separator: ':',
  groupLengths: const [2, 2],
);
final TextInputFormatter concursoCurrencyInputFormatter = _BrazilianCurrencyInputFormatter();

class _FixedDigitsMaskFormatter extends TextInputFormatter {
  _FixedDigitsMaskFormatter({
    required this.maxDigits,
    required this.separator,
    required this.groupLengths,
  });

  final int maxDigits;
  final String separator;
  final List<int> groupLengths;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsBeforeCursor = _digitsBeforeCursor(newValue);
    final digits = _digits(newValue.text, maxDigits);
    final masked = _applyMask(digits);
    final offset = _maskedOffset(
      masked,
      digitsBeforeCursor > digits.length ? digits.length : digitsBeforeCursor,
    );
    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  String _applyMask(String digits) {
    final buffer = StringBuffer();
    var offset = 0;
    for (var index = 0; index < groupLengths.length; index++) {
      if (offset >= digits.length) break;
      final requestedEnd = offset + groupLengths[index];
      final groupEnd = requestedEnd > digits.length ? digits.length : requestedEnd;
      buffer.write(digits.substring(offset, groupEnd));
      offset = groupEnd;
      final completedLength = groupLengths.take(index + 1).fold(0, (sum, length) => sum + length);
      if (offset < maxDigits && offset == completedLength) {
        buffer.write(separator);
      }
    }
    return buffer.toString();
  }
}

class _BrazilianCurrencyInputFormatter extends TextInputFormatter {
  static const _maxDigits = 15;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _digits(newValue.text, _maxDigits);
    if (digits.isEmpty) return TextEditingValue.empty;
    final formatted = formatBrazilianCurrencyInput(int.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String _digits(String value, int maxLength) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  return digits.length > maxLength ? digits.substring(0, maxLength) : digits;
}

int _digitsBeforeCursor(TextEditingValue value) {
  final cursor = value.selection.isValid ? value.selection.extentOffset : value.text.length;
  final safeCursor = cursor < 0 ? 0 : (cursor > value.text.length ? value.text.length : cursor);
  return RegExp(r'\d').allMatches(value.text.substring(0, safeCursor)).length;
}

int _maskedOffset(String masked, int digitCount) {
  if (digitCount == 0) return 0;
  var seen = 0;
  var offset = 0;
  while (offset < masked.length) {
    if (RegExp(r'\d').hasMatch(masked[offset])) seen++;
    offset++;
    if (seen == digitCount) {
      while (offset < masked.length && !RegExp(r'\d').hasMatch(masked[offset])) {
        offset++;
      }
      return offset;
    }
  }
  return masked.length;
}
