import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum AppAvatarSize { sm, md, lg }

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    this.image,
    this.initials,
    this.icon,
    this.size = AppAvatarSize.md,
    this.semanticLabel,
    super.key,
  }) : assert(image != null || initials != null || icon != null, 'Provide an image, initials, or an icon.');

  final ImageProvider<Object>? image;
  final String? initials;
  final IconData? icon;
  final AppAvatarSize size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final dimension = switch (size) {
      AppAvatarSize.sm => context.tokens.sizes.avatarSm,
      AppAvatarSize.md => context.tokens.sizes.avatarMd,
      AppAvatarSize.lg => context.tokens.sizes.avatarLg,
    };
    final fallback = initials != null
        ? Text(initials!, style: context.tokens.typography.labelMedium)
        : Icon(icon, size: context.tokens.icons.sm);
    final child = image == null
        ? fallback
        : ClipOval(
            child: Image(
              image: image!,
              width: dimension,
              height: dimension,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(child: fallback),
            ),
          );
    return Semantics(
      label: semanticLabel,
      image: true,
      child: Container(
        width: dimension,
        height: dimension,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.tokens.colors.surfaceSubtle,
          shape: BoxShape.circle,
          border: Border.all(color: context.tokens.colors.border),
        ),
        child: child,
      ),
    );
  }
}
