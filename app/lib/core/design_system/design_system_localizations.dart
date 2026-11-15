import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';

extension AppLocalizationsBuildContext on BuildContext {
  /// Textos resolvidos para o locale ativo da aplicação.
  ///
  /// O fallback em português mantém componentes isolados e previews
  /// determinísticos quando não estão abaixo de um [Localizations].
  AppLocalizations get l10n => AppLocalizations.of(this) ?? lookupAppLocalizations(const Locale('pt'));
}
