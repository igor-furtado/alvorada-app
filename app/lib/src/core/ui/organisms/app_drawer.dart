import 'package:flutter/material.dart';

import '../../content/app_messages.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_accessible_icon_button.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({required this.title, required this.child, this.description, super.key});

  final String title;
  final String? description;
  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: context.tokens.layout.contentSplit),
      padding: EdgeInsets.all(context.tokens.spacing.lg),
      decoration: BoxDecoration(
        color: context.tokens.colors.popover,
        border: Border(top: BorderSide(color: context.tokens.colors.border)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(context.tokens.borders.radiusXl)),
        boxShadow: context.tokens.shadows.overlay,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.tokens.typography.titleMedium),
                    if (description != null) ...[
                      SizedBox(height: context.tokens.spacing.xs),
                      Text(
                        description!,
                        style: context.tokens.typography.bodySmall.copyWith(
                          color: context.tokens.colors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AppAccessibleIconButton(
                icon: AppIcons.close,
                label: AppMessages.close,
                onPressed: () => Navigator.maybePop(context),
              ),
            ],
          ),
          SizedBox(height: context.tokens.spacing.lg),
          Flexible(child: child),
        ],
      ),
    ),
  );
}

Future<T?> showAppDrawer<T>(
  BuildContext context, {
  required String title,
  required Widget child,
  String? description,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: context.tokens.colors.transparent,
  barrierColor: context.tokens.colors.scrim.withValues(alpha: context.tokens.opacity.dialogBarrier),
  builder: (context) => AppDrawer(title: title, description: description, child: child),
);
