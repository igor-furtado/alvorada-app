enum ConcursosFormStatus { initial, submitting, success, failure }

class ConcursosFormState {
  const ConcursosFormState({
    this.status = ConcursosFormStatus.initial,
    this.errorMessage,
  });

  final ConcursosFormStatus status;
  final String? errorMessage;
}
