import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
import '../../domain/use_cases/disciplinas_use_cases.dart';
import '../topicos_list/topicos_list_state.dart';
import 'topicos_form_bloc.dart';
import 'topicos_form_event.dart';
import 'topicos_form_state.dart';

class TopicosFormView extends StatelessWidget {
  const TopicosFormView({
    required this.disciplineId,
    this.topico,
    super.key,
  });

  final String disciplineId;
  final TopicoListItemData? topico;

  @override
  Widget build(BuildContext context) {
    final useCases = context.read<DisciplinasUseCases>();
    return BlocProvider(
      create: (context) => TopicosFormBloc(
        createTopico: useCases.createTopico,
        updateTopico: useCases.updateTopico,
        disciplineId: disciplineId,
        topicId: topico?.id,
      ),
      child: _TopicosFormContent(topico: topico),
    );
  }
}

class _TopicosFormContent extends StatefulWidget {
  const _TopicosFormContent({required this.topico});

  final TopicoListItemData? topico;

  @override
  State<_TopicosFormContent> createState() => _TopicosFormContentState();
}

class _TopicosFormContentState extends State<_TopicosFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameFocus = FocusNode();
  late final TextEditingController _nameController = TextEditingController(
    text: widget.topico?.name,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<TopicosFormBloc, TopicosFormState>(
    listenWhen: (previous, current) => previous.status != current.status && current.status == TopicosFormStatus.success,
    listener: (context, state) => Navigator.pop(context, true),
    builder: (context, state) => AppValidatedForm(
      formKey: _formKey,
      firstInvalidFocusNode: () => _nameFocus,
      onSubmit: () async {
        final bloc = context.read<TopicosFormBloc>()..add(TopicosFormSubmitted(_nameController.text.trim()));
        await bloc.stream.firstWhere(
          (state) => state.status == TopicosFormStatus.success || state.status == TopicosFormStatus.failure,
        );
      },
      builder: (context, submitting, submit) => AppDialog(
        title: widget.topico == null ? AppMessages.addTopic : AppMessages.editTopic,
        maxWidth: context.tokens.sizes.dialogMedium,
        content: AppFormField(
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
        actions: [
          AppButton(
            label: AppMessages.cancel,
            variant: AppButtonVariant.outline,
            onPressed: submitting ? null : () => Navigator.pop(context),
          ),
          AppButton(
            label: widget.topico == null ? AppMessages.addTopic : AppMessages.saveChanges,
            loading: submitting,
            onPressed: submit,
          ),
        ],
      ),
    ),
  );
}
