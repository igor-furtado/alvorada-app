import 'package:flutter/material.dart';

enum AppLabelStyle { body, caption, control }

class AppLabel extends StatelessWidget {
  const AppLabel(
    this.text, {
    this.style = AppLabelStyle.body,
    this.color,
    this.maxLines,
    this.textAlign,
    super.key,
  });

  final String text;
  final AppLabelStyle style;
  final Color? color;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final textStyle = switch (style) {
      AppLabelStyle.body => Theme.of(context).textTheme.bodyMedium,
      AppLabelStyle.caption => Theme.of(context).textTheme.bodySmall,
      AppLabelStyle.control => Theme.of(context).textTheme.labelLarge,
    };
    return Text(
      text,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      textAlign: textAlign,
      style: textStyle?.copyWith(color: color),
    );
  }
}
