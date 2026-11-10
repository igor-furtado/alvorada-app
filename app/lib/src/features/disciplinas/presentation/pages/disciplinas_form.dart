import 'package:flutter/material.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';

/// Estrutura de formulário usada nas inclusões e edições do catálogo.
class DisciplinasForm extends StatefulWidget {
  const DisciplinasForm({
    required this.title,
    required this.actionLabel,
    this.initialValue,
    this.description,
    this.label = AppMessages.name,
    this.placeholder,
    this.helperText,
    super.key,
  });

  final String title;
  final String actionLabel;
  final String? initialValue;
  final String? description;
  final String label;
  final String? placeholder;
  final String? helperText;

  @override
  State<DisciplinasForm> createState() => _DisciplinasFormState();
}

class _DisciplinasFormState extends State<DisciplinasForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(
    text: widget.initialValue,
  );
  final _nameFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? value) => value == null || value.trim().isEmpty ? AppMessages.requiredField : null;

  @override
  Widget build(BuildContext context) => AppValidatedForm(
    formKey: _formKey,
    firstInvalidFocusNode: () => _nameFocus,
    onSubmit: () async => Navigator.pop(
      context,
      _nameController.text.trim(),
    ),
    builder: (context, submitting, submit) => AppDialog(
      title: widget.title,
      description: widget.description,
      maxWidth: context.tokens.sizes.dialogMedium,
      content: AppFormField(
        label: widget.label,
        placeholder: widget.placeholder,
        helperText: widget.helperText,
        controller: _nameController,
        focusNode: _nameFocus,
        autofocus: true,
        required: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => submit(),
        validator: _validateName,
      ),
      actions: [
        AppButton(
          label: AppMessages.cancel,
          variant: AppButtonVariant.outline,
          onPressed: submitting ? null : () => Navigator.pop(context),
        ),
        AppButton(
          label: widget.actionLabel,
          loading: submitting,
          onPressed: submit,
        ),
      ],
    ),
  );
}
