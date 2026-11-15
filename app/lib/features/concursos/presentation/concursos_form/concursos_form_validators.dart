import 'package:estudos_app/l10n/generated/app_localizations.dart';

import '../concurso_formatters.dart';

abstract final class ConcursosFormValidators {
  static String? requiredText(String? value, AppLocalizations l10n) =>
      value == null || value.trim().isEmpty ? l10n.requiredField : null;

  static String? nonNegativeInteger(String? value, AppLocalizations l10n) {
    try {
      final parsed = parseOptionalInteger(value ?? '');
      return parsed != null && parsed > 1000000 ? l10n.invalidNonNegativeInteger : null;
    } on FormatException {
      return l10n.invalidNonNegativeInteger;
    }
  }

  static String? weeklyWorkload(String? value, AppLocalizations l10n) {
    try {
      final parsed = parseOptionalInteger(value ?? '');
      return parsed != null && (parsed < 1 || parsed > 168) ? l10n.invalidWeeklyWorkload : null;
    } on FormatException {
      return l10n.invalidWeeklyWorkload;
    }
  }

  static String? remuneration(String? value, AppLocalizations l10n) {
    try {
      parseBrazilianCurrency(value ?? '');
      return null;
    } on FormatException {
      return l10n.invalidRemuneration;
    }
  }

  static String? examDate(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      parseBrazilianDate(value);
      return null;
    } on FormatException {
      return l10n.invalidExamDate;
    }
  }

  static String? examTimeRange(String startValue, String endValue, AppLocalizations l10n) {
    final start = startValue.trim();
    final end = endValue.trim();
    if (start.isEmpty && end.isEmpty) return null;
    if (start.isEmpty || end.isEmpty || !isValidTime(start) || !isValidTime(end)) {
      return l10n.invalidExamTimeRange;
    }
    return end.compareTo(start) > 0 ? null : l10n.invalidExamTimeRange;
  }
}
