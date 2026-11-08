import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({this.vertical = false, super.key});

  final bool vertical;

  @override
  Widget build(BuildContext context) => vertical
      ? VerticalDivider(width: context.tokens.spacing.lg, thickness: context.tokens.borders.widthHairline)
      : Divider(height: context.tokens.spacing.lg, thickness: context.tokens.borders.widthHairline);
}
