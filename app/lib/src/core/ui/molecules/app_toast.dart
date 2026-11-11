import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../theme/app_theme.dart';
import '../accessibility/app_accessibility.dart';
import '../atoms/app_accessible_icon_button.dart';
import '../atoms/app_button.dart';
import '../atoms/app_icon.dart';
import '../atoms/app_loading_indicator.dart';
import '../atoms/app_spinner.dart';
import '../responsive/app_responsive.dart';

enum AppToastVariant { neutral, success, info, warning, error, loading }

@immutable
class AppToastHandle {
  const AppToastHandle._(this._id);

  final int _id;

  void update({
    required String title,
    required AppToastVariant variant,
    String? description,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 5),
  }) => AppToast._update(
    _id,
    title: title,
    description: description,
    variant: variant,
    actionLabel: actionLabel,
    onAction: onAction,
    duration: duration,
  );

  void dismiss() => AppToast._dismissById(_id);
}

class AppToast extends StatefulWidget {
  const AppToast({
    required this.title,
    this.description,
    this.variant = AppToastVariant.neutral,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.duration = const Duration(seconds: 5),
    super.key,
  }) : _paused = false,
       _behind = false,
       assert(
         (actionLabel == null) == (onAction == null),
         'actionLabel e onAction devem ser informados juntos.',
       );

  const AppToast._managed({
    required this.title,
    required this.description,
    required this.variant,
    required this.actionLabel,
    required this.onAction,
    required this.onDismiss,
    required this.duration,
    required this._paused,
    required this._behind,
    super.key,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'actionLabel e onAction devem ser informados juntos.',
       );

  final String title;
  final String? description;
  final AppToastVariant variant;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;
  final Duration duration;
  final bool _paused;
  final bool _behind;

  static const _visibleLimit = 3;
  static final List<_AppToastData> _toasts = [];
  static OverlayEntry? _overlayEntry;
  static OverlayState? _overlayState;
  static var _nextId = 0;

  static AppToastHandle show(
    BuildContext context, {
    required String title,
    String? description,
    AppToastVariant variant = AppToastVariant.neutral,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 5),
  }) {
    assert(
      (actionLabel == null) == (onAction == null),
      'actionLabel e onAction devem ser informados juntos.',
    );

    final overlay = Overlay.of(context, rootOverlay: true);
    if (!identical(_overlayState, overlay)) {
      _removeOverlayImmediately();
      _overlayState = overlay;
    }

    final id = _nextId++;
    _toasts.add(
      _AppToastData(
        id: id,
        key: GlobalKey<_AppToastState>(),
        title: title,
        description: description,
        variant: variant,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
      ),
    );
    if (_toasts.length > _visibleLimit) _toasts.removeAt(0);

    _overlayEntry ??= OverlayEntry(builder: _buildOverlay);
    if (!_overlayEntry!.mounted) {
      overlay.insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }
    _announce(context, title: title, description: description, variant: variant);
    return AppToastHandle._(id);
  }

  static Widget _buildOverlay(BuildContext overlayContext) {
    final tokens = overlayContext.tokens;
    final media = MediaQuery.of(overlayContext);
    final inset = tokens.spacing.lg;
    final width = math.min<double>(
      tokens.layout.dialogMaxWidth,
      math.max<double>(0, media.size.width - inset * 2),
    );

    return Positioned.directional(
      textDirection: Directionality.of(overlayContext),
      end: inset,
      bottom: inset + media.viewPadding.bottom,
      width: width,
      child: _AppToastViewport(
        toasts: List.unmodifiable(_toasts),
        onDismiss: _removeById,
      ),
    );
  }

  static void dismiss([AppToastHandle? toast]) {
    final id = toast?._id ?? (_toasts.isEmpty ? null : _toasts.last.id);
    if (id != null) _dismissById(id);
  }

  static void dismissAll() {
    for (final toast in List<_AppToastData>.of(_toasts)) {
      final state = toast.key.currentState;
      if (state == null) {
        _removeById(toast.id);
      } else {
        unawaited(state.dismiss());
      }
    }
  }

  static void _update(
    int id, {
    required String title,
    required String? description,
    required AppToastVariant variant,
    required String? actionLabel,
    required VoidCallback? onAction,
    required Duration duration,
  }) {
    assert(
      (actionLabel == null) == (onAction == null),
      'actionLabel e onAction devem ser informados juntos.',
    );
    final index = _toasts.indexWhere((toast) => toast.id == id);
    if (index < 0) return;
    final previous = _toasts[index];
    _toasts[index] = _AppToastData(
      id: id,
      key: previous.key,
      title: title,
      description: description,
      variant: variant,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
    _overlayEntry?.markNeedsBuild();
    final overlayContext = _overlayState?.context;
    if (overlayContext != null) {
      _announce(overlayContext, title: title, description: description, variant: variant);
    }
  }

  static void _dismissById(int id) {
    final index = _toasts.indexWhere((toast) => toast.id == id);
    if (index < 0) return;
    final state = _toasts[index].key.currentState;
    if (state == null) {
      _removeById(id);
    } else {
      unawaited(state.dismiss());
    }
  }

  static void _removeById(int id) {
    _toasts.removeWhere((toast) => toast.id == id);
    if (_toasts.isEmpty) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _overlayState = null;
    } else {
      _overlayEntry?.markNeedsBuild();
    }
  }

  static void _announce(
    BuildContext context, {
    required String title,
    required String? description,
    required AppToastVariant variant,
  }) {
    AppAccessibility.announce(
      context,
      [title, ?description].join('. '),
      assertiveness: variant == AppToastVariant.error ? Assertiveness.assertive : Assertiveness.polite,
    );
  }

  static void _removeOverlayImmediately() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _overlayState = null;
    _toasts.clear();
  }

  @override
  State<AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<AppToast> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tokens = context.tokens;
    _controller
      ..duration = context.motionDuration(tokens.motion.medium)
      ..reverseDuration = context.motionDuration(tokens.motion.fast);
    if (!_controller.isAnimating && _controller.value == 0) {
      unawaited(_controller.forward());
      _resumeTimer();
    }
  }

  @override
  void didUpdateWidget(covariant AppToast oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration ||
        oldWidget.variant != widget.variant ||
        oldWidget._paused != widget._paused) {
      if (widget._paused) {
        _pauseTimer();
      } else {
        _resumeTimer();
      }
    }
  }

  void _pauseTimer() => _timer?.cancel();

  void _resumeTimer() {
    _pauseTimer();
    if (widget.onDismiss == null ||
        widget.duration == Duration.zero ||
        widget.variant == AppToastVariant.loading ||
        widget._paused ||
        _dismissing) {
      return;
    }
    _timer = Timer(widget.duration, () => unawaited(dismiss()));
  }

  Future<void> dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    _pauseTimer();
    await _controller.reverse();
    if (mounted) widget.onDismiss?.call();
  }

  void _performAction() {
    widget.onAction?.call();
    unawaited(dismiss());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final offset = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: tokens.motion.enter, reverseCurve: tokens.motion.exit));

    return MouseRegion(
      onEnter: (_) => _pauseTimer(),
      onExit: (_) => _resumeTimer(),
      child: Focus(
        onFocusChange: (focused) => focused ? _pauseTimer() : _resumeTimer(),
        child: Dismissible(
          key: ValueKey('${widget.title}-${widget.description}'),
          direction: DismissDirection.horizontal,
          onDismissed: (_) => widget.onDismiss?.call(),
          child: FadeTransition(
            opacity: _controller,
            child: SlideTransition(
              position: offset,
              child: Semantics(
                container: true,
                explicitChildNodes: true,
                hidden: widget._behind,
                label: [widget.title, ?widget.description].join('. '),
                child: Material(
                  color: tokens.colors.transparent,
                  child: Container(
                    padding: EdgeInsets.all(tokens.spacing.lg),
                    decoration: BoxDecoration(
                      color: tokens.colors.popover,
                      border: Border.all(
                        color: tokens.colors.border,
                        width: tokens.borders.widthHairline,
                      ),
                      borderRadius: tokens.borders.xxl,
                      boxShadow: tokens.shadows.overlay,
                    ),
                    child: widget._behind
                        ? const SizedBox.shrink()
                        : _AppToastContent(
                            title: widget.title,
                            description: widget.description,
                            variant: widget.variant,
                            actionLabel: widget.actionLabel,
                            onAction: widget.onAction == null ? null : _performAction,
                            onDismiss: () => unawaited(dismiss()),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class _AppToastData {
  const _AppToastData({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.variant,
    required this.actionLabel,
    required this.onAction,
    required this.duration,
  });

  final int id;
  final GlobalKey<_AppToastState> key;
  final String title;
  final String? description;
  final AppToastVariant variant;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
}

class _AppToastViewport extends StatefulWidget {
  const _AppToastViewport({required this.toasts, required this.onDismiss});

  final List<_AppToastData> toasts;
  final ValueChanged<int> onDismiss;

  @override
  State<_AppToastViewport> createState() => _AppToastViewportState();
}

class _AppToastViewportState extends State<_AppToastViewport> {
  bool _hovered = false;
  bool _focused = false;

  bool get _expanded => _hovered || _focused;

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  void _setFocused(bool value) {
    if (_focused == value) return;
    setState(() => _focused = value);
  }

  Widget _buildToast(_AppToastData toast, {required bool behind}) {
    final child = AppToast._managed(
      key: toast.key,
      title: toast.title,
      description: toast.description,
      variant: toast.variant,
      actionLabel: toast.actionLabel,
      onAction: toast.onAction,
      onDismiss: () => widget.onDismiss(toast.id),
      duration: toast.duration,
      paused: _expanded,
      behind: behind,
    );
    return IgnorePointer(
      ignoring: behind,
      child: ExcludeFocus(excluding: behind, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final toasts = widget.toasts;
    final expanded = _expanded;
    final content = expanded
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < toasts.length; index++) ...[
                if (index > 0) SizedBox(height: tokens.spacing.md),
                _buildToast(toasts[index], behind: false),
              ],
            ],
          )
        : LayoutBuilder(
            builder: (context, constraints) {
              final stackOffset = tokens.spacing.md;
              final frontIndex = toasts.length - 1;
              return Padding(
                padding: EdgeInsets.only(top: stackOffset * frontIndex),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (var index = 0; index < frontIndex; index++)
                      Positioned.fill(
                        child: Builder(
                          builder: (context) {
                            final depth = frontIndex - index;
                            final inset = tokens.spacing.xl * depth;
                            final horizontalScale = constraints.maxWidth <= 0
                                ? 1.0
                                : math.max<double>(0, (constraints.maxWidth - inset * 2) / constraints.maxWidth);
                            return Transform.translate(
                              offset: Offset(0, -stackOffset * depth),
                              child: Transform(
                                alignment: Alignment.bottomCenter,
                                transform: Matrix4.diagonal3Values(horizontalScale, 1, 1),
                                child: _buildToast(toasts[index], behind: true),
                              ),
                            );
                          },
                        ),
                      ),
                    _buildToast(toasts[frontIndex], behind: false),
                  ],
                ),
              );
            },
          );

    return MouseRegion(
      key: const ValueKey('app-toast-viewport'),
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: Focus(
        onFocusChange: _setFocused,
        child: AnimatedSize(
          alignment: Alignment.bottomCenter,
          duration: context.motionDuration(tokens.motion.medium),
          curve: tokens.motion.standard,
          clipBehavior: Clip.none,
          child: content,
        ),
      ),
    );
  }
}

class _AppToastContent extends StatelessWidget {
  const _AppToastContent({
    required this.title,
    required this.description,
    required this.variant,
    required this.actionLabel,
    required this.onAction,
    required this.onDismiss,
  });

  final String title;
  final String? description;
  final AppToastVariant variant;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final status = _status(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final scaled = MediaQuery.textScalerOf(context).scale(1) > 1.5;
        final compact = scaled || constraints.maxWidth < tokens.layout.dialogMaxWidth - tokens.spacing.giant;
        final close = AppAccessibleIconButton(
          icon: AppIcons.close,
          label: 'Fechar notificação',
          onPressed: onDismiss,
        );
        final action = actionLabel != null && onAction != null
            ? AppButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: AppButtonVariant.outline,
              )
            : null;

        if (compact) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (status != null) ...[
                    Padding(
                      padding: EdgeInsets.only(top: tokens.spacing.xxxs),
                      child: status,
                    ),
                    SizedBox(width: tokens.spacing.md),
                  ],
                  Expanded(child: _buildText(context)),
                  SizedBox(width: tokens.spacing.md),
                  close,
                ],
              ),
              if (action != null) ...[
                SizedBox(height: tokens.spacing.md),
                action,
              ],
            ],
          );
        }

        return Row(
          children: [
            if (status != null) ...[
              status,
              SizedBox(width: tokens.spacing.md),
            ],
            Expanded(child: _buildText(context)),
            if (action != null) ...[
              SizedBox(width: tokens.spacing.md),
              action,
            ],
            SizedBox(width: tokens.spacing.md),
            close,
          ],
        );
      },
    );
  }

  Widget _buildText(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: tokens.typography.labelLarge),
        if (description != null) ...[
          SizedBox(height: tokens.spacing.xxs),
          Text(description!, style: tokens.typography.bodySmall),
        ],
      ],
    );
  }

  Widget? _status(BuildContext context) {
    final tokens = context.tokens;
    return switch (variant) {
      AppToastVariant.neutral => null,
      AppToastVariant.success => AppIcon(
        AppIcons.checkCircle,
        size: AppIconSize.sm,
        color: tokens.colors.onSurface,
      ),
      AppToastVariant.info => AppIcon(
        AppIcons.info,
        size: AppIconSize.sm,
        color: tokens.colors.onSurface,
      ),
      AppToastVariant.warning => AppIcon(
        AppIcons.attention,
        size: AppIconSize.sm,
        color: tokens.colors.onSurface,
      ),
      AppToastVariant.error => AppIcon(
        AppIcons.error,
        size: AppIconSize.sm,
        color: tokens.colors.error,
      ),
      AppToastVariant.loading => AppSpinner(
        size: AppLoadingSize.sm,
        semanticLabel: 'Carregando',
        color: tokens.colors.onSurface,
      ),
    };
  }
}
