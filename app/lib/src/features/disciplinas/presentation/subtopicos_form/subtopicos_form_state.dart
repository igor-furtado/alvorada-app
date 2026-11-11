enum SubtopicosFormStatus { initial, submitting, success, failure }

class SubtopicosFormState {
  const SubtopicosFormState({
    this.status = SubtopicosFormStatus.initial,
    this.errorMessage,
  });

  final SubtopicosFormStatus status;
  final String? errorMessage;
}
