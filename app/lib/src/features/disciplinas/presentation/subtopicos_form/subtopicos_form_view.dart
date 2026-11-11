import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/ui/app_ui.dart';
import '../../domain/use_cases/disciplinas_use_cases.dart';
import '../subtopicos_list/subtopicos_list_state.dart';
import 'subtopicos_form_bloc.dart';
import 'subtopicos_form_event.dart';
import 'subtopicos_form_state.dart';

class SubtopicosFormView extends StatelessWidget {
  const SubtopicosFormView({
    required this.topicId,
    this.subtopico,
    super.key,
  });

  final String topicId;
  final SubtopicoListItemData? subtopico;

  @override
  Widget build(BuildContext context) {
    final useCases = context.read<DisciplinasUseCases>();
    return BlocProvider(
      create: (context) => SubtopicosFormBloc(
        createSubtopico: useCases.createSubtopico,
        updateSubtopico: useCases.updateSubtopico,
        topicId: topicId,
        subtopicId: subtopico?.id,
      ),
      child: _SubtopicosFormContent(subtopico: subtopico),
    );
  }
}

class _SubtopicosFormContent extends StatefulWidget {
  const _SubtopicosFormContent({required this.subtopico});

  final SubtopicoListItemData? subtopico;

  @override
  State<_SubtopicosFormContent> createState() => _SubtopicosFormContentState();
}

class _SubtopicosFormContentState extends State<_SubtopicosFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameFocus = FocusNode();
  late final TextEditingController _nameController = TextEditingController(
    text: widget.subtopico?.name,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<SubtopicosFormBloc, SubtopicosFormState>(
    listenWhen: (previous, current) =>
        previous.status != current.status && current.status == SubtopicosFormStatus.success,
    listener: (context, state) => Navigator.pop(context, true),
    builder: (context, state) => AppValidatedForm(
      formKey: _formKey,
      firstInvalidFocusNode: () => _nameFocus,
      onSubmit: () async {
        final bloc = context.read<SubtopicosFormBloc>()..add(SubtopicosFormSubmitted(_nameController.text.trim()));
        await bloc.stream.firstWhere(
          (state) => state.status == SubtopicosFormStatus.success || state.status == SubtopicosFormStatus.failure,
        );
      },
      builder: (context, submitting, submit) => AppDrawer(
        title: widget.subtopico == null ? AppMessages.addSubtopic : AppMessages.editSubtopic,
        dismissible: !submitting,
        primaryLabel: widget.subtopico == null ? AppMessages.addSubtopic : AppMessages.saveChanges,
        onPrimary: submit,
        loading: submitting,
        secondaryLabel: AppMessages.cancel,
        onSecondary: submitting ? null : () => Navigator.pop(context),
        child: AppFormField(
          label: AppMessages.name,
          errorText: state.errorMessage,
          controller: _nameController,
          focusNode: _nameFocus,
          autofocus: true,
          required: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => submit(),
          validator: (value) => value == null || value.trim().isEmpty ? AppMessages.requiredField : null,
        ),
      ),
    ),
  );
}
