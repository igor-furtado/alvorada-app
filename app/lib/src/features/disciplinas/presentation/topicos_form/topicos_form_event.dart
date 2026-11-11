sealed class TopicosFormEvent {
  const TopicosFormEvent();
}

final class TopicosFormSubmitted extends TopicosFormEvent {
  const TopicosFormSubmitted(this.name);

  final String name;
}
