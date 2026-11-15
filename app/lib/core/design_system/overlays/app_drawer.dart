import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_icons.dart';
import '../app_tokens.dart';
import '../controls/app_button.dart';
import '../design_system_localizations.dart';
import '../layout/app_responsive.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    required this.title,
    required this.description,
    required this.child,
    this.eyebrow,
    this.primaryLabel,
    this.onPrimary,
    this.loading = false,
    this.dismissible = true,
    super.key,
  });

  final String title;
  final String? eyebrow;
  final String description;
  final Widget child;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final bool loading;
  final bool dismissible;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final footerActions = <Widget>[
      if (primaryLabel != null)
        AppButton(
          label: primaryLabel!,
          onPressed: onPrimary,
          loading: loading,
        ),
    ];

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (dismissible) unawaited(Navigator.maybePop(context));
        },
      },
      child: Focus(
        autofocus: true,
        child: PopScope(
          canPop: dismissible,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewport = MediaQuery.sizeOf(context);
              final width = constraints.hasBoundedWidth ? constraints.maxWidth : viewport.width;
              final height = constraints.hasBoundedHeight ? constraints.maxHeight : viewport.height;
              final panelWidth = math.min(width, tokens.layout.drawerWidth);
              final panel = Semantics(
                scopesRoute: true,
                namesRoute: true,
                explicitChildNodes: true,
                label: title,
                child: FocusTraversalGroup(
                  child: Container(
                    key: const ValueKey('app-drawer-surface'),
                    width: panelWidth,
                    height: height,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: tokens.colors.popover,
                      border: Border(left: BorderSide(color: tokens.colors.border)),
                      boxShadow: tokens.overlayShadow,
                    ),
                    child: Material(
                      color: tokens.colors.transparent,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                        child: _AppDrawerPanel(
                          eyebrow: eyebrow,
                          title: title,
                          description: description,
                          footerActions: footerActions,
                          dismissible: dismissible,
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              );
              final dismissiblePanel = dismissible
                  ? Dismissible(
                      key: ValueKey('app-drawer-$title'),
                      direction: _dismissDirection(context),
                      resizeDuration: Duration.zero,
                      confirmDismiss: (_) async {
                        await Navigator.maybePop(context);
                        return false;
                      },
                      child: panel,
                    )
                  : panel;

              return SafeArea(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: dismissiblePanel,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AppDrawerPanel extends StatelessWidget {
  const _AppDrawerPanel({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.footerActions,
    required this.dismissible,
    required this.child,
  });

  final String? eyebrow;
  final String title;
  final String description;
  final List<Widget> footerActions;
  final bool dismissible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AppDrawerHeader(
          eyebrow: eyebrow,
          title: title,
          description: description,
          dismissible: dismissible,
        ),
        Expanded(child: _AppDrawerBody(child: child)),
        if (footerActions.isNotEmpty) _AppDrawerFooter(actions: footerActions),
      ],
    );
  }
}

class _AppDrawerHeader extends StatelessWidget {
  const _AppDrawerHeader({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.dismissible,
  });

  final String? eyebrow;
  final String title;
  final String description;
  final bool dismissible;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.spacing.xxl,
        tokens.spacing.xxl,
        tokens.spacing.xxl,
        tokens.spacing.none,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[
                  Text(
                    eyebrow!,
                    style: tokens.typography.bodySmall.copyWith(color: tokens.colors.onSurfaceMuted),
                  ),
                  SizedBox(height: tokens.spacing.xs),
                ],
                Text(title, style: tokens.typography.headlineSmall),
                SizedBox(height: tokens.spacing.xs),
                Text(
                  description,
                  style: tokens.typography.bodyMedium.copyWith(color: tokens.colors.onSurfaceMuted),
                ),
              ],
            ),
          ),
          if (dismissible) ...[
            SizedBox(width: tokens.spacing.lg),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: tokens.colors.border),
                borderRadius: tokens.borders.lg,
              ),
              child: IconButton(
                tooltip: context.l10n.close,
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(AppIcons.close),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AppDrawerBody extends StatelessWidget {
  const _AppDrawerBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.all(context.tokens.spacing.xxl),
    child: child,
  );
}

class _AppDrawerFooter extends StatelessWidget {
  const _AppDrawerFooter({required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.spacing.xxl,
        tokens.spacing.none,
        tokens.spacing.xxl,
        tokens.spacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < actions.length; index++) ...[
            if (index > 0) SizedBox(height: tokens.spacing.sm),
            actions[index],
          ],
        ],
      ),
    );
  }
}

Future<T?> showAppDrawerBuilder<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool dismissible = true,
  bool useRootNavigator = true,
}) => _showAppDrawerRoute<T>(
  context,
  dismissible: dismissible,
  useRootNavigator: useRootNavigator,
  builder: builder,
);

Future<T?> _showAppDrawerRoute<T>(
  BuildContext context, {
  required bool dismissible,
  required bool useRootNavigator,
  required WidgetBuilder builder,
}) {
  final tokens = context.tokens;
  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: dismissible,
    barrierLabel: context.l10n.close,
    barrierColor: tokens.colors.scrim.withValues(alpha: tokens.opacity.drawerBarrier),
    transitionDuration: context.motionDuration(tokens.motion.drawer),
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: tokens.motion.drawerEnter,
        reverseCurve: tokens.motion.exit,
      );
      return Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: tokens.overlayBackdropBlur,
                sigmaY: tokens.overlayBackdropBlur,
              ),
              child: ColoredBox(color: tokens.colors.transparent),
            ),
          ),
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        ],
      );
    },
  );
}

DismissDirection _dismissDirection(BuildContext context) {
  final leftToRight = Directionality.of(context) == TextDirection.ltr;
  return leftToRight ? DismissDirection.startToEnd : DismissDirection.endToStart;
}
