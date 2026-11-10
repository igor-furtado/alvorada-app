import 'package:flutter/material.dart';

import 'app_state_view.dart';

class AppEmpty extends StatelessWidget {
  const AppEmpty({
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => AppStateView(
    variant: AppStateVariant.empty,
    title: title,
    message: description,
    actionLabel: actionLabel,
    onAction: onAction,
  );
}
