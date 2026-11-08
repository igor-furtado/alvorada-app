import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum AppAvatarSize { sm, md, lg }

class AppAvatar extends StatelessWidget {
  const AppAvatar({this.initials, this.icon, this.size = AppAvatarSize.md, this.semanticLabel, super.key})
    : assert(initials != null || icon != null, 'Provide initials or an icon.');

  final String? initials;
  final IconData? icon;
  final AppAvatarSize size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final dimension = switch (size) {
      AppAvatarSize.sm => context.tokens.sizes.iconContainerSm,
      AppAvatarSize.md => context.tokens.sizes.identityIcon,
      AppAvatarSize.lg => context.tokens.sizes.largeVisual,
    };
    final child = initials != null
        ? Text(initials!, style: Theme.of(context).textTheme.labelLarge)
        : Icon(icon, size: context.tokens.icons.md);
    return Semantics(
      label: semanticLabel,
      image: true,
      child: Container(
        width: dimension,
        height: dimension,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }
}
