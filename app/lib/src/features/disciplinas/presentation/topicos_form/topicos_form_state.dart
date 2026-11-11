enum TopicosFormStatus { initial, submitting, success, failure }

class TopicosFormState {
  const TopicosFormState({
    this.status = TopicosFormStatus.initial,
    this.errorMessage,
  });

  final TopicosFormStatus status;
  final String? errorMessage;
}
