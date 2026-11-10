import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppProgress extends StatelessWidget {
  const AppProgress({required this.value, this.semanticLabel = 'Progresso', super.key})
    : assert(value >= 0 && value <= 1, 'Progress must be between 0 and 1.');

  final double value;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    value: '${(value * 100).round()}%',
    child: ClipRRect(
      borderRadius: context.tokens.borders.full,
      child: SizedBox(
        height: context.tokens.spacing.xxs,
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: context.tokens.colors.surfaceSubtle,
          color: context.tokens.colors.primary,
        ),
      ),
    ),
  );
}
