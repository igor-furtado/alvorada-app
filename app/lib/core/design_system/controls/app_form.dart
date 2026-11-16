import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

import '../../accessibility/app_accessibility.dart';
import '../app_tokens.dart';
import '../design_system_localizations.dart';

typedef AppFormBuilder = Widget Function(
  BuildContext context,
  bool submitting,
  VoidCallback submit,
  Widget content,
);

typedef AppFormContentBuilder = List<Widget> Function(
  BuildContext context,
  bool submitting,
  VoidCallback submit,
);

class AppForm extends StatefulWidget {
  const AppForm({
    required this.contentBuilder,
    required this.builder,
    required this.onSubmit,
    this.firstInvalidFocusNode,
    this.title,
    this.description,
    this.spacing,
    super.key,
  });

  final AppFormContentBuilder contentBuilder;
  final AppFormBuilder builder;
  final Future<void> Function() onSubmit;
  final FocusNode? Function()? firstInvalidFocusNode;
  final String? title;
  final String? description;
  final double? spacing;

  @override
  State<AppForm> createState() => _AppFormState();
}

class _AppFormState extends State<AppForm> {
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  Future<void> _submit() async {
    if (_submitting) return;
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      widget.firstInvalidFocusNode?.call()?.requestFocus();
      AppAccessibility.announce(context, context.l10n.formHasErrors, assertiveness: Assertiveness.assertive);
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.onSubmit();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = widget.spacing ?? tokens.spacing.lg;
    final children = widget.contentBuilder(context, _submitting, _submit);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null) Text(widget.title!, style: tokens.typography.titleSmall),
        if (widget.description != null) ...[
          if (widget.title != null) SizedBox(height: tokens.spacing.xxs),
          Text(
            widget.description!,
            style: tokens.typography.supportingText,
          ),
        ],
        if (widget.title != null || widget.description != null) SizedBox(height: spacing),
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index != children.length - 1) SizedBox(height: spacing),
        ],
      ],
    );

    return FocusTraversalGroup(
      child: Form(
        key: _formKey,
        child: widget.builder(context, _submitting, _submit, content),
      ),
    );
  }
}
