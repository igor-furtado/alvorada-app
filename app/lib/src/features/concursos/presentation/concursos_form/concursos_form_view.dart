import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/app_messages.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/app_ui.dart';
import '../../domain/models/concurso_input.dart';
import '../../domain/use_cases/concursos_use_cases.dart';
import '../concurso_formatters.dart';
import 'concursos_form_bloc.dart';
import 'concursos_form_event.dart';
import 'concursos_form_state.dart';

class ConcursosFormView extends StatelessWidget {
  const ConcursosFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final useCases = context.read<ConcursosUseCases>();
    return BlocProvider(
      create: (_) => ConcursosFormBloc(
        createConcurso: useCases.createConcurso,
      ),
      child: const _ConcursosFormContent(),
    );
  }
}

class _ConcursosFormContent extends StatefulWidget {
  const _ConcursosFormContent();

  @override
  State<_ConcursosFormContent> createState() => _ConcursosFormContentState();
}

class _ConcursosFormContentState extends State<_ConcursosFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _instituicao = TextEditingController();
  final _cargo = TextEditingController();
  final _banca = TextEditingController();
  final _dataProva = TextEditingController();
  final _instituicaoFocus = FocusNode();
  final _cargoFocus = FocusNode();
  var _prioritario = false;

  @override
  void dispose() {
    _instituicao.dispose();
    _cargo.dispose();
    _banca.dispose();
    _dataProva.dispose();
    _instituicaoFocus.dispose();
    _cargoFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<ConcursosFormBloc, ConcursosFormState>(
    listenWhen: (previous, current) =>
        previous.status != current.status && current.status == ConcursosFormStatus.success,
    listener: (context, state) => Navigator.pop(context, true),
    builder: (context, state) => AppValidatedForm(
      formKey: _formKey,
      firstInvalidFocusNode: () {
        if (_instituicao.text.trim().isEmpty) return _instituicaoFocus;
        if (_cargo.text.trim().isEmpty) return _cargoFocus;
        return null;
      },
      onSubmit: () async {
        final bloc = context.read<ConcursosFormBloc>()..add(ConcursosFormSubmitted(_input));
        await bloc.stream.firstWhere(
          (state) => state.status == ConcursosFormStatus.success || state.status == ConcursosFormStatus.failure,
        );
      },
      builder: (context, submitting, submit) => AppDialog(
        title: AppMessages.novoConcurso,
        maxWidth: context.tokens.sizes.dialogNarrow,
        content: AppFieldGroup(
          children: [
            AppFormField(
              label: AppMessages.institution,
              controller: _instituicao,
              focusNode: _instituicaoFocus,
              autofocus: true,
              required: true,
              errorText: state.errorMessage,
              validator: _required,
            ),
            AppFormField(
              label: AppMessages.role,
              controller: _cargo,
              focusNode: _cargoFocus,
              required: true,
              validator: _required,
            ),
            AppFormField(
              label: AppMessages.board,
              controller: _banca,
            ),
            AppFormField(
              label: AppMessages.examDate,
              controller: _dataProva,
              placeholder: AppMessages.examDatePlaceholder,
              keyboardType: TextInputType.datetime,
              validator: _validDate,
            ),
            AppField(
              label: AppMessages.concursoPrioritarioField,
              description: AppMessages.concursoPrioritarioHelp,
              orientation: AppFieldOrientation.horizontal,
              control: AppCheckbox(
                value: _prioritario,
                semanticLabel: AppMessages.concursoPrioritarioField,
                onChanged: submitting
                    ? null
                    : (value) => setState(
                        () => _prioritario = value ?? false,
                      ),
              ),
            ),
          ],
        ),
        actions: [
          AppButton(
            label: AppMessages.cancel,
            variant: AppButtonVariant.outline,
            onPressed: submitting ? null : () => Navigator.pop(context),
          ),
          AppButton(
            label: AppMessages.criarConcurso,
            loading: submitting,
            onPressed: submit,
          ),
        ],
      ),
    ),
  );

  CreateConcursoInput get _input => CreateConcursoInput(
    instituicao: _instituicao.text,
    cargo: _cargo.text,
    banca: _banca.text,
    dataProva: parseBrazilianDate(_dataProva.text),
    prioritario: _prioritario,
  );

  String? _required(String? value) => value == null || value.trim().isEmpty ? AppMessages.requiredField : null;

  String? _validDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      parseBrazilianDate(value);
      return null;
    } on FormatException {
      return AppMessages.invalidExamDate;
    }
  }
}
