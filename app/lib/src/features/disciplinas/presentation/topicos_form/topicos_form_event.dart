sealed class TopicosFormEvent {
  const TopicosFormEvent();
}

final class TopicosFormSubmitted extends TopicosFormEvent {
  const TopicosFormSubmitted(this.names);

  final List<String> names;
}
