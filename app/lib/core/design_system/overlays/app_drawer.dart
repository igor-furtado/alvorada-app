import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

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
    this.onDismissRequested,
    this.width,
    this.scrollable = true,
    this.bodyPadding,
    this.footer,
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
  final Future<bool> Function()? onDismissRequested;
  final double? width;
  final bool scrollable;
  final EdgeInsetsGeometry? bodyPadding;
  final Widget? footer;

  Future<void> _requestDismiss(BuildContext context) async {
    if (!dismissible) return;
    final allowed = await onDismissRequested?.call() ?? true;
    if (allowed && context.mounted) Navigator.pop(context);
  }

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
          if (dismissible) unawaited(_requestDismiss(context));
        },
      },
      child: Focus(
        autofocus: true,
        child: PopScope(
          canPop: dismissible && onDismissRequested == null,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && dismissible) unawaited(_requestDismiss(context));
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewport = MediaQuery.sizeOf(context);
              final width = constraints.hasBoundedWidth ? constraints.maxWidth : viewport.width;
              final height = constraints.hasBoundedHeight ? constraints.maxHeight : viewport.height;
              final panelWidth = math.min(width, this.width ?? tokens.layout.drawerWidth);
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
                      border: Border(
                        left: BorderSide(
                          color: context.highContrast ? tokens.colors.onSurface : tokens.colors.border,
                          width: context.highContrast ? tokens.borders.widthStrong : tokens.borders.widthHairline,
                        ),
                      ),
                      boxShadow: tokens.overlayShadow,
                    ),
                    child: Material(
                      color: tokens.colors.transparent,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          final drawerFocus = Focus.of(context);
                          FocusManager.instance.primaryFocus?.unfocus();
                          drawerFocus.requestFocus();
                        },
                        child: _AppDrawerPanel(
                          eyebrow: eyebrow,
                          title: title,
                          description: description,
                          footerActions: footerActions,
                          footer: footer,
                          dismissible: dismissible,
                          onDismiss: () => _requestDismiss(context),
                          scrollable: scrollable,
                          bodyPadding: bodyPadding,
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              );
              final dismissiblePanel = dismissible
                  ? _AppDrawerGestureSurface(
                      key: ValueKey('app-drawer-$title'),
                      width: panelWidth,
                      onDismiss: () => _requestDismiss(context),
                      child: panel,
                    )
                  : panel;

              return Stack(
                fit: StackFit.expand,
                children: [
                  if (dismissible)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => unawaited(_requestDismiss(context)),
                    ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: dismissiblePanel,
                    ),
                  ),
                ],
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
    required this.footer,
    required this.dismissible,
    required this.onDismiss,
    required this.scrollable,
    required this.bodyPadding,
    required this.child,
  });

  final String? eyebrow;
  final String title;
  final String description;
  final List<Widget> footerActions;
  final Widget? footer;
  final bool dismissible;
  final VoidCallback onDismiss;
  final bool scrollable;
  final EdgeInsetsGeometry? bodyPadding;
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
          onDismiss: onDismiss,
        ),
        Expanded(
          child: _AppDrawerBody(
            scrollable: scrollable,
            padding: bodyPadding,
            child: child,
          ),
        ),
        if (footer != null) footer! else if (footerActions.isNotEmpty) _AppDrawerFooter(actions: footerActions),
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
    required this.onDismiss,
  });

  final String? eyebrow;
  final String title;
  final String description;
  final bool dismissible;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      key: const ValueKey('app-drawer-header'),
      padding: EdgeInsets.fromLTRB(
        tokens.spacing.xxl,
        tokens.spacing.xxl,
        tokens.spacing.xxl,
        tokens.spacing.xl,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tokens.colors.border)),
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
                    style: tokens.typography.supportingText,
                  ),
                  SizedBox(height: tokens.spacing.xs),
                ],
                Text(title, style: tokens.typography.headlineSmall),
                SizedBox(height: tokens.spacing.xs),
                Text(
                  description,
                  style: tokens.typography.description,
                ),
              ],
            ),
          ),
          if (dismissible) ...[
            SizedBox(width: tokens.spacing.lg),
            IconButton(
              tooltip: context.l10n.close,
              onPressed: onDismiss,
              icon: const Icon(AppIcons.close),
            ),
          ],
        ],
      ),
    );
  }
}

class _AppDrawerBody extends StatelessWidget {
  const _AppDrawerBody({
    required this.scrollable,
    required this.padding,
    required this.child,
  });

  final bool scrollable;
  final EdgeInsetsGeometry? padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final padded = Padding(
      padding: padding ?? EdgeInsets.all(context.tokens.spacing.xxl),
      child: child,
    );
    return scrollable ? SingleChildScrollView(child: padded) : padded;
  }
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
    barrierDismissible: false,
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
          if (!context.reduceTransparency)
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

class _AppDrawerGestureSurface extends StatefulWidget {
  const _AppDrawerGestureSurface({
    required this.width,
    required this.onDismiss,
    required this.child,
    super.key,
  });

  final double width;
  final VoidCallback onDismiss;
  final Widget child;

  @override
  State<_AppDrawerGestureSurface> createState() => _AppDrawerGestureSurfaceState();
}

class _AppDrawerGestureSurfaceState extends State<_AppDrawerGestureSurface> with SingleTickerProviderStateMixin {
  late final AnimationController _offset = AnimationController.unbounded(vsync: this);
  var _settleGeneration = 0;

  double get _direction => Directionality.of(context) == TextDirection.ltr ? 1 : -1;

  @override
  void dispose() {
    _offset.dispose();
    super.dispose();
  }

  void _start(DragStartDetails details) {
    _settleGeneration++;
    _offset.stop();
  }

  void _update(DragUpdateDetails details) {
    final delta = (details.primaryDelta ?? 0) * _direction;
    final next = _offset.value + delta;
    _offset.value = next < 0 ? _rubberBand(next, widget.width) : math.min(next, widget.width);
  }

  Future<void> _end(DragEndDetails details) async {
    final velocity = details.primaryVelocity == null ? 0.0 : details.primaryVelocity! * _direction;
    final projected = _offset.value + _project(velocity);
    final shouldClose = projected > widget.width * .5;
    final generation = ++_settleGeneration;
    if (context.reduceMotion) {
      _offset.value = shouldClose ? widget.width : 0;
    } else {
      final simulation = SpringSimulation(
        SpringDescription.withDampingRatio(
          mass: 1,
          stiffness: shouldClose ? 440 : 360,
          ratio: shouldClose ? .82 : 1,
        ),
        _offset.value,
        shouldClose ? widget.width : 0,
        velocity,
      );
      await _offset.animateWith(simulation);
    }
    if (!mounted || generation != _settleGeneration || !shouldClose) return;
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.translucent,
    onHorizontalDragStart: _start,
    onHorizontalDragUpdate: _update,
    onHorizontalDragEnd: _end,
    child: AnimatedBuilder(
      animation: _offset,
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset: Offset(_offset.value * _direction, 0),
        child: child,
      ),
    ),
  );
}

double _project(double velocity, [double decelerationRate = .998]) =>
    (velocity / 1000) * decelerationRate / (1 - decelerationRate);

double _rubberBand(double overshoot, double dimension, [double constant = .55]) =>
    (overshoot * dimension * constant) / (dimension + constant * overshoot.abs());
