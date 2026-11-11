enum DisciplinasFormStatus { initial, submitting, success, failure }

class DisciplinasFormState {
  const DisciplinasFormState({
    this.status = DisciplinasFormStatus.initial,
    this.errorMessage,
  });

  final DisciplinasFormStatus status;
  final String? errorMessage;
}
