import 'package:flutter/material.dart';

import '../../content/app_messages.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_accessible_icon_button.dart';
import '../responsive/app_responsive.dart';

enum AppSheetSide { left, right, top, bottom }

class AppSheet extends StatelessWidget {
  const AppSheet({
    required this.title,
    required this.child,
    this.description,
    this.side = AppSheetSide.right,
    super.key,
  });

  final String title;
  final String? description;
  final Widget child;
  final AppSheetSide side;

  @override
  Widget build(BuildContext context) {
    final horizontal = side == AppSheetSide.left || side == AppSheetSide.right;
    return Align(
      alignment: switch (side) {
        AppSheetSide.left => Alignment.centerLeft,
        AppSheetSide.right => Alignment.centerRight,
        AppSheetSide.top => Alignment.topCenter,
        AppSheetSide.bottom => Alignment.bottomCenter,
      },
      child: SafeArea(
        child: Container(
          width: horizontal ? context.tokens.layout.dialogMaxWidth : double.infinity,
          height: horizontal ? double.infinity : context.tokens.sizes.overviewPanel,
          padding: EdgeInsets.all(context.tokens.spacing.lg),
          decoration: BoxDecoration(
            color: context.tokens.colors.popover,
            border: Border.all(color: context.tokens.colors.border),
            boxShadow: context.tokens.shadows.overlay,
          ),
          child: Material(
            color: context.tokens.colors.transparent,
            child: Column(
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
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> showAppSheet<T>(
  BuildContext context, {
  required String title,
  required Widget child,
  String? description,
  AppSheetSide side = AppSheetSide.right,
}) {
  final tokens = context.tokens;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: AppMessages.close,
    barrierColor: tokens.colors.scrim.withValues(alpha: tokens.opacity.dialogBarrier),
    transitionDuration: context.motionDuration(tokens.motion.medium),
    pageBuilder: (context, animation, secondaryAnimation) => AppSheet(
      title: title,
      description: description,
      side: side,
      child: child,
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
      opacity: animation,
      child: child,
    ),
  );
}
