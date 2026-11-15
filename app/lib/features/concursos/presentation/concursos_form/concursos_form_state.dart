enum ConcursosFormStatus { initial, submitting, success, failure }

class ConcursosFormState {
  const ConcursosFormState({
    this.status = ConcursosFormStatus.initial,
    this.errorCode,
  });

  final ConcursosFormStatus status;
  final String? errorCode;
}
