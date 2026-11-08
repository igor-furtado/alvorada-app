import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppSkeleton extends StatelessWidget {
  const AppSkeleton({required this.height, this.width = double.infinity, this.semanticLabel, super.key});

  final double height;
  final double width;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    liveRegion: semanticLabel != null,
    child: ExcludeSemantics(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: context.tokens.borders.md,
        ),
      ),
    ),
  );
}
