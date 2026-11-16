import 'package:material_ui/material_ui.dart';

import '../app_tokens.dart';
import 'app_responsive.dart';

class AppCard extends StatefulWidget {
  const AppCard({
    required this.child,
    this.onTap,
    this.padding,
    this.backgroundColor,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = widget.padding ?? EdgeInsets.all(context.tokens.spacing.lg);
    final content = Padding(padding: effectivePadding, child: widget.child);
    final card = Material(
      color: widget.backgroundColor ?? context.tokens.colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: context.tokens.borders.xl,
        side: BorderSide(
          color: context.highContrast ? context.tokens.colors.onSurface : context.tokens.colors.border,
          width: context.highContrast ? context.tokens.borders.widthStrong : context.tokens.borders.widthHairline,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: widget.onTap == null
          ? content
          : InkWell(
              onTap: widget.onTap,
              onHighlightChanged: (value) => setState(() => _pressed = value),
              excludeFromSemantics: true,
              hoverColor: context.tokens.colors.surfaceSubtle,
              child: content,
            ),
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      button: widget.onTap != null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed && !context.reduceMotion ? .995 : 1,
        duration: context.motionDuration(context.tokens.motion.fast),
        curve: context.tokens.motion.enter,
        child: card,
      ),
    );
  }
}
