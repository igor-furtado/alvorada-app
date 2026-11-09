import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../theme/app_theme.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({this.vertical = false, super.key});

  final bool vertical;

  @override
  Widget build(BuildContext context) => vertical
      ? ShadSeparator.vertical(
          margin: EdgeInsets.symmetric(horizontal: context.tokens.spacing.sm),
          thickness: context.tokens.borders.widthHairline,
        )
      : ShadSeparator.horizontal(
          margin: EdgeInsets.symmetric(vertical: context.tokens.spacing.sm),
          thickness: context.tokens.borders.widthHairline,
        );
}
