import '../../../../core/content/app_messages.dart';
import '../concurso_formatters.dart';

abstract final class ConcursosFormValidators {
  static String? requiredText(String? value) =>
      value == null || value.trim().isEmpty ? AppMessages.requiredField : null;

  static String? nonNegativeInteger(String? value) {
    try {
      final parsed = parseOptionalInteger(value ?? '');
      return parsed != null && parsed > 1000000 ? AppMessages.invalidNonNegativeInteger : null;
    } on FormatException {
      return AppMessages.invalidNonNegativeInteger;
    }
  }

  static String? weeklyWorkload(String? value) {
    try {
      final parsed = parseOptionalInteger(value ?? '');
      return parsed != null && (parsed < 1 || parsed > 168) ? AppMessages.invalidWeeklyWorkload : null;
    } on FormatException {
      return AppMessages.invalidWeeklyWorkload;
    }
  }

  static String? remuneration(String? value) {
    try {
      parseBrazilianCurrency(value ?? '');
      return null;
    } on FormatException {
      return AppMessages.invalidRemuneration;
    }
  }

  static String? examDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      parseBrazilianDate(value);
      return null;
    } on FormatException {
      return AppMessages.invalidExamDate;
    }
  }

  static String? examTimeRange(String startValue, String endValue) {
    final start = startValue.trim();
    final end = endValue.trim();
    if (start.isEmpty && end.isEmpty) return null;
    if (start.isEmpty || end.isEmpty || !isValidTime(start) || !isValidTime(end)) {
      return AppMessages.invalidExamTimeRange;
    }
    return end.compareTo(start) > 0 ? null : AppMessages.invalidExamTimeRange;
  }
}
