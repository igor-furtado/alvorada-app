enum DisciplinasFormStatus { initial, submitting, success, failure }

class DisciplinasFormState {
  const DisciplinasFormState({
    this.status = DisciplinasFormStatus.initial,
    this.errorCode,
  });

  final DisciplinasFormStatus status;
  final String? errorCode;
}
