import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({this.vertical = false, this.margin, super.key});

  final bool vertical;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final separator = ColoredBox(
      color: context.tokens.colors.border,
      child: SizedBox(
        width: vertical ? context.tokens.borders.widthHairline : double.infinity,
        height: vertical ? double.infinity : context.tokens.borders.widthHairline,
      ),
    );
    return Padding(
      padding:
          margin ??
          (vertical
              ? EdgeInsets.symmetric(horizontal: context.tokens.spacing.sm)
              : EdgeInsets.symmetric(vertical: context.tokens.spacing.sm)),
      child: separator,
    );
  }
}
