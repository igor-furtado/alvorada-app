import 'package:estudos_app/core/design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/use_cases/disciplinas_use_cases.dart';
import '../disciplinas_list/disciplinas_list_state.dart';
import '../disciplinas_localizations.dart';
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
          label: context.l10n.disciplineName,
          errorText: state.errorCode == null ? null : context.l10n.disciplineFormError(state.errorCode),
          required: true,
          control: AppTextInput(
            controller: _nameController,
            focusNode: _nameFocus,
            placeholder: context.l10n.disciplineNameExample,
            errorText: state.errorCode == null ? null : context.l10n.disciplineFormError(state.errorCode),
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => submit(),
            validator: (value) => value == null || value.trim().isEmpty ? context.l10n.requiredField : null,
            semanticLabel: '${context.l10n.disciplineName}, ${context.l10n.requiredSuffix}',
          ),
        ),
      ],
      builder: (context, submitting, submit, content) => AppDrawer(
        title: widget.disciplina == null ? context.l10n.newDiscipline : context.l10n.editDiscipline,
        description: widget.disciplina == null
            ? context.l10n.newDisciplineDescription
            : context.l10n.editDisciplineDescription,
        dismissible: !submitting,
        primaryLabel: widget.disciplina == null ? context.l10n.addDiscipline : context.l10n.saveChanges,
        onPrimary: submit,
        loading: submitting,
        child: content,
      ),
    ),
  );
}
