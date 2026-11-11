import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../content/app_messages.dart';
import '../../theme/app_theme.dart';
import '../atoms/app_button.dart';
import '../responsive/app_responsive.dart';

enum AppDrawerDirection { up, right, down, left }

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    required this.title,
    required this.child,
    this.description,
    this.direction,
    this.showSwipeHandle,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.actions = const [],
    this.destructive = false,
    this.loading = false,
    this.dismissible = true,
    super.key,
  });

  final String title;
  final String? description;
  final Widget child;
  final AppDrawerDirection? direction;
  final bool? showSwipeHandle;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final List<Widget> actions;
  final bool destructive;
  final bool loading;
  final bool dismissible;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final resolvedDirection = direction ?? _responsiveDirection(context);
    final horizontal = resolvedDirection == AppDrawerDirection.left || resolvedDirection == AppDrawerDirection.right;
    final displayHandle = showSwipeHandle ?? context.windowClass.isCompact;
    final footerActions = <Widget>[
      if (primaryLabel != null)
        AppButton(
          label: primaryLabel!,
          variant: destructive ? AppButtonVariant.destructive : AppButtonVariant.primary,
          onPressed: onPrimary,
          loading: loading,
        ),
      if (secondaryLabel != null)
        AppButton(
          label: secondaryLabel!,
          variant: AppButtonVariant.outline,
          onPressed: onSecondary,
        ),
      ...actions,
    ];

    return PopScope(
      canPop: dismissible,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = MediaQuery.sizeOf(context);
          final width = constraints.hasBoundedWidth ? constraints.maxWidth : viewport.width;
          final height = constraints.hasBoundedHeight ? constraints.maxHeight : viewport.height;
          final panelWidth = horizontal
              ? math.min(width * tokens.layout.drawerSideFraction, tokens.layout.dialogMaxWidth)
              : width;
          final panelHeight = horizontal ? height : null;
          final maxPanelHeight = math.max(tokens.spacing.none, height - (tokens.spacing.huge * 2));
          final panel = Semantics(
            scopesRoute: true,
            namesRoute: true,
            explicitChildNodes: true,
            label: title,
            child: FocusTraversalGroup(
              child: Container(
                key: const ValueKey('app-drawer-surface'),
                width: panelWidth,
                height: panelHeight,
                constraints: horizontal ? null : BoxConstraints(maxHeight: maxPanelHeight),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: tokens.colors.popover,
                  border: Border.all(
                    color: tokens.colors.border,
                    width: tokens.borders.widthHairline,
                  ),
                  borderRadius: tokens.borders.xxxl,
                  boxShadow: tokens.shadows.overlay,
                ),
                child: Material(
                  color: tokens.colors.transparent,
                  child: _AppDrawerPanel(
                    title: title,
                    description: description,
                    direction: resolvedDirection,
                    showSwipeHandle: displayHandle,
                    footerActions: footerActions,
                    child: child,
                  ),
                ),
              ),
            ),
          );
          final dismissiblePanel = dismissible
              ? Dismissible(
                  key: ValueKey('app-drawer-${resolvedDirection.name}-$title'),
                  direction: _dismissDirection(context, resolvedDirection),
                  resizeDuration: Duration.zero,
                  confirmDismiss: (_) async {
                    await Navigator.maybePop(context);
                    return false;
                  },
                  child: panel,
                )
              : panel;

          return SafeArea(
            minimum: EdgeInsets.all(tokens.spacing.sm),
            child: Align(
              alignment: _alignment(resolvedDirection),
              child: dismissiblePanel,
            ),
          );
        },
      ),
    );
  }
}

class _AppDrawerPanel extends StatelessWidget {
  const _AppDrawerPanel({
    required this.title,
    required this.description,
    required this.direction,
    required this.showSwipeHandle,
    required this.footerActions,
    required this.child,
  });

  final String title;
  final String? description;
  final AppDrawerDirection direction;
  final bool showSwipeHandle;
  final List<Widget> footerActions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final horizontal = direction == AppDrawerDirection.left || direction == AppDrawerDirection.right;
    final content = Column(
      mainAxisSize: horizontal ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AppDrawerHeader(title: title, description: description, horizontal: horizontal),
        if (horizontal)
          Expanded(child: _AppDrawerBody(child: child))
        else
          Flexible(child: _AppDrawerBody(child: child)),
        if (footerActions.isNotEmpty) _AppDrawerFooter(actions: footerActions),
      ],
    );

    if (!showSwipeHandle) return content;
    final handle = _AppDrawerSwipeHandle(horizontal: horizontal);
    return switch (direction) {
      AppDrawerDirection.up => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(child: content),
          handle,
        ],
      ),
      AppDrawerDirection.down => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          handle,
          Flexible(child: content),
        ],
      ),
      AppDrawerDirection.left => Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: content),
          handle,
        ],
      ),
      AppDrawerDirection.right => Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          handle,
          Expanded(child: content),
        ],
      ),
    };
  }
}

class _AppDrawerHeader extends StatelessWidget {
  const _AppDrawerHeader({required this.title, required this.description, required this.horizontal});

  final String title;
  final String? description;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final centered = !horizontal && context.windowClass.isCompact;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.spacing.lg,
        tokens.spacing.lg,
        tokens.spacing.lg,
        tokens.spacing.none,
      ),
      child: Column(
        crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: tokens.typography.titleMedium.copyWith(fontWeight: FontWeight.w500),
          ),
          if (description != null) ...[
            SizedBox(height: centered ? tokens.spacing.xs : tokens.spacing.xxxs),
            Text(
              description!,
              textAlign: centered ? TextAlign.center : TextAlign.start,
              style: tokens.typography.bodySmall.copyWith(color: tokens.colors.onSurfaceMuted),
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
    padding: EdgeInsets.all(context.tokens.spacing.lg),
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
        tokens.spacing.lg,
        tokens.spacing.none,
        tokens.spacing.lg,
        tokens.spacing.lg,
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

class _AppDrawerSwipeHandle extends StatelessWidget {
  const _AppDrawerSwipeHandle({required this.horizontal});

  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ExcludeSemantics(
      child: SizedBox(
        key: const ValueKey('app-drawer-swipe-handle'),
        width: horizontal ? tokens.spacing.md : double.infinity,
        height: horizontal ? double.infinity : tokens.spacing.md,
        child: Center(
          child: Container(
            width: horizontal ? tokens.spacing.xs : tokens.sizes.drawerHandleLength,
            height: horizontal ? tokens.sizes.drawerHandleLength : tokens.spacing.xs,
            decoration: BoxDecoration(
              color: tokens.colors.surfaceSubtle,
              borderRadius: tokens.borders.full,
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> showAppDrawer<T>(
  BuildContext context, {
  required String title,
  required Widget child,
  String? description,
  AppDrawerDirection? direction,
  bool? showSwipeHandle,
  String? primaryLabel,
  VoidCallback? onPrimary,
  String? secondaryLabel,
  VoidCallback? onSecondary,
  List<Widget> actions = const [],
  bool destructive = false,
  bool loading = false,
  bool dismissible = true,
  bool useRootNavigator = true,
}) {
  final resolvedDirection = direction ?? _responsiveDirection(context);
  final displayHandle = showSwipeHandle ?? context.windowClass.isCompact;
  return _showAppDrawerRoute<T>(
    context,
    direction: resolvedDirection,
    dismissible: dismissible,
    useRootNavigator: useRootNavigator,
    builder: (context) => AppDrawer(
      title: title,
      description: description,
      direction: resolvedDirection,
      showSwipeHandle: displayHandle,
      primaryLabel: primaryLabel,
      onPrimary: onPrimary,
      secondaryLabel: secondaryLabel,
      onSecondary: onSecondary,
      actions: actions,
      destructive: destructive,
      loading: loading,
      dismissible: dismissible,
      child: child,
    ),
  );
}

Future<T?> showAppDrawerBuilder<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool dismissible = true,
  bool useRootNavigator = true,
}) => _showAppDrawerRoute<T>(
  context,
  direction: _responsiveDirection(context),
  dismissible: dismissible,
  useRootNavigator: useRootNavigator,
  builder: builder,
);

Future<T?> _showAppDrawerRoute<T>(
  BuildContext context, {
  required AppDrawerDirection direction,
  required bool dismissible,
  required bool useRootNavigator,
  required WidgetBuilder builder,
}) {
  final tokens = context.tokens;
  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: dismissible,
    barrierLabel: AppMessages.close,
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
                sigmaX: tokens.sizes.dialogBackdropBlur,
                sigmaY: tokens.sizes.dialogBackdropBlur,
              ),
              child: ColoredBox(color: tokens.colors.transparent),
            ),
          ),
          SlideTransition(
            position: Tween<Offset>(
              begin: _transitionOffset(direction),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        ],
      );
    },
  );
}

AppDrawerDirection _responsiveDirection(BuildContext context) =>
    context.windowClass.isCompact ? AppDrawerDirection.down : AppDrawerDirection.right;

Alignment _alignment(AppDrawerDirection direction) => switch (direction) {
  AppDrawerDirection.up => Alignment.topCenter,
  AppDrawerDirection.right => Alignment.centerRight,
  AppDrawerDirection.down => Alignment.bottomCenter,
  AppDrawerDirection.left => Alignment.centerLeft,
};

Offset _transitionOffset(AppDrawerDirection direction) => switch (direction) {
  AppDrawerDirection.up => const Offset(0, -1),
  AppDrawerDirection.right => const Offset(1, 0),
  AppDrawerDirection.down => const Offset(0, 1),
  AppDrawerDirection.left => const Offset(-1, 0),
};

DismissDirection _dismissDirection(BuildContext context, AppDrawerDirection direction) {
  final leftToRight = Directionality.of(context) == TextDirection.ltr;
  return switch (direction) {
    AppDrawerDirection.up => DismissDirection.up,
    AppDrawerDirection.right => leftToRight ? DismissDirection.startToEnd : DismissDirection.endToStart,
    AppDrawerDirection.down => DismissDirection.down,
    AppDrawerDirection.left => leftToRight ? DismissDirection.endToStart : DismissDirection.startToEnd,
  };
}
