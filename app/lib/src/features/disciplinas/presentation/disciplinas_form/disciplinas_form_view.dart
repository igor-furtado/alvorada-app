import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/ui/app_ui.dart';
import '../../domain/use_cases/disciplinas_use_cases.dart';
import '../disciplinas_list/disciplinas_list_state.dart';
import 'disciplinas_form_bloc.dart';
import 'disciplinas_form_event.dart';
import 'disciplinas_form_state.dart';

class DisciplinasFormView extends StatelessWidget {
  const DisciplinasFormView({this.disciplina, super.key});

  final DisciplinaListItemData? disciplina;

  @override
  Widget build(BuildContext context) {
    final useCases = context.read<DisciplinasUseCases>();
    return BlocProvider(
      create: (context) => DisciplinasFormBloc(
        createDisciplina: useCases.createDisciplina,
        updateDisciplina: useCases.updateDisciplina,
        disciplineId: disciplina?.id,
      ),
      child: _DisciplinasFormContent(disciplina: disciplina),
    );
  }
}

class _DisciplinasFormContent extends StatefulWidget {
  const _DisciplinasFormContent({required this.disciplina});

  final DisciplinaListItemData? disciplina;

  @override
  State<_DisciplinasFormContent> createState() => _DisciplinasFormContentState();
}

class _DisciplinasFormContentState extends State<_DisciplinasFormContent> {
  final _nameFocus = FocusNode();
  late final TextEditingController _nameController = TextEditingController(
    text: widget.disciplina?.name,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<DisciplinasFormBloc, DisciplinasFormState>(
    listenWhen: (previous, current) =>
        previous.status != current.status && current.status == DisciplinasFormStatus.success,
    listener: (context, state) => Navigator.pop(context, true),
    builder: (context, state) => AppForm(
      firstInvalidFocusNode: () => _nameFocus,
      onSubmit: () async {
        final bloc = context.read<DisciplinasFormBloc>()..add(DisciplinasFormSubmitted(_nameController.text.trim()));
        await bloc.stream.firstWhere(
          (state) => state.status == DisciplinasFormStatus.success || state.status == DisciplinasFormStatus.failure,
        );
      },
      contentBuilder: (context, submitting, submit) => [
        AppField(
          label: AppMessages.disciplineName,
          errorText: state.errorMessage,
          required: true,
          control: AppTextInput(
            controller: _nameController,
            focusNode: _nameFocus,
            placeholder: AppMessages.disciplineNameExample,
            errorText: state.errorMessage,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => submit(),
            validator: (value) => value == null || value.trim().isEmpty ? AppMessages.requiredField : null,
            semanticLabel: '${AppMessages.disciplineName}, ${AppMessages.requiredSuffix}',
          ),
        ),
      ],
      builder: (context, submitting, submit, content) => AppDrawer(
        title: widget.disciplina == null ? AppMessages.newDiscipline : AppMessages.editDiscipline,
        description: widget.disciplina == null ? AppMessages.newDisciplineDescription : null,
        dismissible: !submitting,
        primaryLabel: widget.disciplina == null ? AppMessages.addDiscipline : AppMessages.saveChanges,
        onPrimary: submit,
        loading: submitting,
        child: content,
      ),
    ),
  );
}
