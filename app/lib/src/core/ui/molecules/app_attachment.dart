import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_icon.dart';
import '../atoms/app_loading_indicator.dart';
import '../atoms/app_progress.dart';
import '../atoms/app_spinner.dart';

enum AppAttachmentState { idle, uploading, processing, error, done }

enum AppAttachmentSize { defaultSize, sm, xs }

enum AppAttachmentOrientation { horizontal, vertical }

class AppAttachment extends StatelessWidget {
  const AppAttachment({
    required this.title,
    this.description,
    this.media,
    this.actions = const [],
    this.state = AppAttachmentState.done,
    this.size = AppAttachmentSize.defaultSize,
    this.progress,
    this.orientation = AppAttachmentOrientation.horizontal,
    this.onTap,
    super.key,
  });

  final String title;
  final String? description;
  final Widget? media;
  final List<Widget> actions;
  final AppAttachmentState state;
  final AppAttachmentSize size;
  final double? progress;
  final AppAttachmentOrientation orientation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final error = state == AppAttachmentState.error;
    final idle = state == AppAttachmentState.idle;
    final mediaDimension = switch (size) {
      AppAttachmentSize.defaultSize => 40.0,
      AppAttachmentSize.sm => 32.0,
      AppAttachmentSize.xs => 28.0,
    };
    final padding = switch (size) {
      AppAttachmentSize.defaultSize => EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm + tokens.spacing.xxxs,
        vertical: tokens.spacing.sm,
      ),
      AppAttachmentSize.sm => EdgeInsets.symmetric(
        horizontal: tokens.spacing.sm,
        vertical: tokens.spacing.xs,
      ),
      AppAttachmentSize.xs => EdgeInsets.symmetric(
        horizontal: tokens.spacing.xs,
        vertical: tokens.spacing.xxs,
      ),
    };
    final gap = switch (size) {
      AppAttachmentSize.defaultSize => tokens.spacing.sm,
      AppAttachmentSize.sm => tokens.spacing.sm + tokens.spacing.xxxs,
      AppAttachmentSize.xs => tokens.spacing.xs,
    };
    final titleStyle = switch (size) {
      AppAttachmentSize.defaultSize => tokens.typography.labelLarge,
      AppAttachmentSize.sm || AppAttachmentSize.xs => tokens.typography.labelMedium.copyWith(
        color: tokens.colors.onSurface,
      ),
    };
    final descriptionStyle = tokens.typography.labelMedium.copyWith(
      color: error ? tokens.colors.error : tokens.colors.onSurfaceMuted,
      fontWeight: FontWeight.w400,
    );
    final mediaForeground = error ? tokens.colors.error : tokens.colors.onSurface;
    final mediaWidget = media ?? _defaultMedia(mediaForeground);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _AttachmentTitle(
          text: title,
          style: titleStyle,
          shimmer: state == AppAttachmentState.uploading || state == AppAttachmentState.processing,
        ),
        if (description != null) ...[
          SizedBox(height: tokens.spacing.xxxs),
          Text(
            description!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: descriptionStyle,
          ),
        ],
        if (progress != null) ...[
          SizedBox(height: tokens.spacing.sm),
          AppProgress(value: progress!.clamp(0, 1), semanticLabel: title),
        ],
      ],
    );
    final children = <Widget>[
      Container(
        key: const ValueKey('app-attachment-media'),
        width: orientation == AppAttachmentOrientation.vertical ? double.infinity : mediaDimension,
        height: mediaDimension,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: error ? tokens.colors.errorContainer : tokens.colors.surfaceSubtle,
          borderRadius: size == AppAttachmentSize.xs ? tokens.borders.md : tokens.borders.lg,
        ),
        child: mediaWidget,
      ),
      SizedBox(
        width: orientation == AppAttachmentOrientation.horizontal ? gap : 0,
        height: orientation == AppAttachmentOrientation.vertical ? gap : 0,
      ),
      if (orientation == AppAttachmentOrientation.horizontal) Expanded(child: content) else content,
      if (actions.isNotEmpty) ...[
        SizedBox(
          width: orientation == AppAttachmentOrientation.horizontal ? tokens.spacing.xxs : 0,
          height: orientation == AppAttachmentOrientation.vertical ? tokens.spacing.xxs : 0,
        ),
        Wrap(spacing: tokens.spacing.xxs, children: actions),
      ],
    ];
    final radius = size == AppAttachmentSize.xs ? tokens.borders.xl : tokens.borders.xxl;
    final borderColor = error ? tokens.colors.error.withValues(alpha: .30) : tokens.colors.border;
    final attachment = Material(
      key: const ValueKey('app-attachment-surface'),
      color: tokens.colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: idle ? BorderSide.none : BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: orientation == AppAttachmentOrientation.horizontal
              ? Row(mainAxisSize: MainAxisSize.max, children: children)
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ),
    );
    return Semantics(
      container: true,
      button: onTap != null,
      child: idle
          ? CustomPaint(
              foregroundPainter: _DashedRoundedBorderPainter(
                color: borderColor,
                radius: radius.topLeft.x,
                strokeWidth: tokens.borders.widthHairline,
              ),
              child: attachment,
            )
          : attachment,
    );
  }

  Widget _defaultMedia(Color color) => switch (state) {
    AppAttachmentState.idle => AppIcon(AppIcons.clock, size: AppIconSize.sm, color: color),
    AppAttachmentState.uploading => AppSpinner(
      size: AppLoadingSize.sm,
      color: color,
      semanticLabel: 'Enviando $title',
    ),
    AppAttachmentState.processing => AppIcon(AppIcons.fileText, size: AppIconSize.sm, color: color),
    AppAttachmentState.error => AppIcon(AppIcons.fileWarning, size: AppIconSize.sm, color: color),
    AppAttachmentState.done => AppIcon(AppIcons.check, size: AppIconSize.sm, color: color),
  };
}

class _AttachmentTitle extends StatefulWidget {
  const _AttachmentTitle({required this.text, required this.style, required this.shimmer});

  final String text;
  final TextStyle style;
  final bool shimmer;

  @override
  State<_AttachmentTitle> createState() => _AttachmentTitleState();
}

class _AttachmentTitleState extends State<_AttachmentTitle> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate = widget.shimmer && !MediaQuery.disableAnimationsOf(context);
    if (animate && !_controller.isAnimating) {
      unawaited(_controller.repeat());
    } else if (!animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void didUpdateWidget(covariant _AttachmentTitle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shimmer != widget.shimmer) {
      final animate = widget.shimmer && !MediaQuery.disableAnimationsOf(context);
      if (animate) {
        unawaited(_controller.repeat());
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Text(
      widget.text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: widget.style,
    );
    if (!widget.shimmer || MediaQuery.disableAnimationsOf(context)) return text;
    final colors = context.tokens.colors;
    return AnimatedBuilder(
      animation: _controller,
      child: text,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment(-2 + (_controller.value * 4), 0),
          end: Alignment(-1 + (_controller.value * 4), 0),
          colors: [colors.onSurfaceMuted, colors.onSurface, colors.onSurfaceMuted],
        ).createShader(bounds),
        child: child,
      ),
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  const _DashedRoundedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(inset, inset, size.width - strokeWidth, size.height - strokeWidth),
          Radius.circular(radius),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    for (final metric in path.computeMetrics()) {
      var offset = 0.0;
      while (offset < metric.length) {
        canvas.drawPath(metric.extractPath(offset, offset + 4), paint);
        offset += 8;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter oldDelegate) =>
      color != oldDelegate.color || radius != oldDelegate.radius || strokeWidth != oldDelegate.strokeWidth;
}
