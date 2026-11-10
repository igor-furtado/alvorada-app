import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_icon.dart';

@immutable
class AppMetricData {
  const AppMetricData({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;
}

class AppMetricItem extends StatelessWidget {
  const AppMetricItem({required this.data, required this.backgroundColor, required this.foregroundColor, super.key});

  final AppMetricData data;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: context.tokens.sizes.overviewPanel,
    child: Row(
      children: [
        Container(
          width: context.tokens.sizes.iconContainerMd,
          height: context.tokens.sizes.iconContainerMd,
          decoration: BoxDecoration(color: backgroundColor, borderRadius: context.tokens.borders.md),
          child: AppIcon(data.icon, color: foregroundColor),
        ),
        SizedBox(width: context.tokens.spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.value, style: context.tokens.typography.titleMedium),
              Text(data.label, style: context.tokens.typography.bodySmall),
            ],
          ),
        ),
      ],
    ),
  );
}
