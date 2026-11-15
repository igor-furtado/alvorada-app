enum TopicosFormStatus { initial, submitting, success, failure }

class TopicosFormState {
  const TopicosFormState({
    this.status = TopicosFormStatus.initial,
    this.errorCode,
  });

  final TopicosFormStatus status;
  final String? errorCode;
}
