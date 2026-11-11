import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../content/app_messages.dart';
import '../../theme/app_theme.dart';

@immutable
class AppBreadcrumbItem {
  const AppBreadcrumbItem({required this.label, this.route}) : ellipsis = false, onPressed = null;

  const AppBreadcrumbItem.ellipsis({this.onPressed}) : label = '', route = null, ellipsis = true;

  final String label;
  final String? route;
  final bool ellipsis;
  final VoidCallback? onPressed;
}

class AppBreadcrumbs extends StatelessWidget {
  const AppBreadcrumbs({required this.items, super.key});

  final List<AppBreadcrumbItem> items;

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppMessages.navigationPath,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            if (index > 0) ...[
              SizedBox(width: context.tokens.spacing.sm),
              ExcludeSemantics(
                child: Icon(
                  AppIcons.chevronRight,
                  size: context.tokens.icons.sm - context.tokens.spacing.xxxs,
                  color: context.tokens.colors.onSurfaceMuted,
                ),
              ),
              SizedBox(width: context.tokens.spacing.sm),
            ],
            if (items[index].ellipsis)
              _BreadcrumbEllipsis(onPressed: items[index].onPressed)
            else if (items[index].route case final route?)
              Semantics(
                link: true,
                child: InkWell(
                  onTap: () => context.go(route),
                  borderRadius: context.tokens.borders.sm,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: context.tokens.spacing.xxl),
                    child: Center(
                      child: Text(
                        items[index].label,
                        style: context.tokens.typography.bodySmall.copyWith(
                          color: context.tokens.colors.onSurfaceMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              Semantics(
                selected: true,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: context.tokens.spacing.xxl),
                  child: Center(
                    child: Text(
                      items[index].label,
                      style: context.tokens.typography.bodySmall.copyWith(
                        color: context.tokens.colors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    ),
  );
}

class _BreadcrumbEllipsis extends StatelessWidget {
  const _BreadcrumbEllipsis({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = SizedBox.square(
      dimension: context.tokens.spacing.xl,
      child: Center(
        child: Icon(
          AppIcons.more,
          size: context.tokens.icons.sm,
          color: context.tokens.colors.onSurfaceMuted,
        ),
      ),
    );
    if (onPressed == null) return ExcludeSemantics(child: icon);
    return Semantics(
      label: AppMessages.moreActions,
      button: true,
      onTap: onPressed,
      excludeSemantics: true,
      child: Tooltip(
        message: AppMessages.moreActions,
        child: InkWell(
          onTap: onPressed,
          borderRadius: context.tokens.borders.sm,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: context.tokens.layout.controlHeight),
            child: icon,
          ),
        ),
      ),
    );
  }
}
