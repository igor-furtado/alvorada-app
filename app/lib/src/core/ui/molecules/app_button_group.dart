import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppButtonGroup extends StatelessWidget {
  const AppButtonGroup({required this.children, this.direction = Axis.horizontal, super.key});

  final List<Widget> children;
  final Axis direction;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: context.tokens.borders.lg,
    child: direction == Axis.horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: _withSeparators(context))
        : Column(mainAxisSize: MainAxisSize.min, children: _withSeparators(context)),
  );

  List<Widget> _withSeparators(BuildContext context) => [
    for (var index = 0; index < children.length; index++) ...[
      if (index > 0)
        SizedBox(
          width: direction == Axis.horizontal ? context.tokens.borders.widthHairline : 0,
          height: direction == Axis.vertical ? context.tokens.borders.widthHairline : 0,
        ),
      children[index],
    ],
  ];
}
