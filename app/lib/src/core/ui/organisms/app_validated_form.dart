import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../content/app_messages.dart';
import '../accessibility/app_accessibility.dart';

typedef AppValidatedFormBuilder = Widget Function(BuildContext context, bool submitting, VoidCallback submit);

class AppValidatedForm extends StatefulWidget {
  const AppValidatedForm({
    required this.formKey,
    required this.builder,
    required this.onSubmit,
    this.firstInvalidFocusNode,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final AppValidatedFormBuilder builder;
  final Future<void> Function() onSubmit;
  final FocusNode? Function()? firstInvalidFocusNode;

  @override
  State<AppValidatedForm> createState() => _AppValidatedFormState();
}

class _AppValidatedFormState extends State<AppValidatedForm> {
  bool _submitting = false;

  Future<void> _submit() async {
    if (_submitting) return;
    final valid = widget.formKey.currentState?.validate() ?? false;
    if (!valid) {
      widget.firstInvalidFocusNode?.call()?.requestFocus();
      AppAccessibility.announce(context, AppMessages.formHasErrors, assertiveness: Assertiveness.assertive);
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
  Widget build(BuildContext context) => FocusTraversalGroup(
    child: Form(
      key: widget.formKey,
      child: widget.builder(context, _submitting, _submit),
    ),
  );
}
