import 'package:flutter/material.dart';

import '../../content/app_messages.dart';
import 'app_loading_indicator.dart';

/// Indicador compacto para operações sem progresso mensurável.
class AppSpinner extends StatelessWidget {
  const AppSpinner({this.size = AppLoadingSize.md, this.color, this.semanticLabel, super.key});

  final AppLoadingSize size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => AppLoadingIndicator(
    size: size,
    color: color,
    semanticLabel: semanticLabel ?? AppMessages.loading,
  );
}
