import 'package:flutter/material.dart';

import '../../content/app_messages.dart';
import '../../theme/app_theme.dart';

enum AppLoadingSize { sm, md, lg }

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    this.size = AppLoadingSize.md,
    this.color,
    this.semanticLabel = AppMessages.loading,
    super.key,
  });

  final AppLoadingSize size;
  final Color? color;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final dimension = switch (size) {
      AppLoadingSize.sm => context.tokens.icons.sm,
      AppLoadingSize.md => context.tokens.icons.md,
      AppLoadingSize.lg => context.tokens.icons.lg,
    };
    return Semantics(
      label: semanticLabel,
      liveRegion: true,
      child: SizedBox.square(
        dimension: dimension,
        child: CircularProgressIndicator(
          color: color,
          strokeWidth: context.tokens.borders.widthStrong,
        ),
      ),
    );
  }
}
